# Shoplive iOS SDK XCFramework installer (DRAFT-flutter-sdk-302-ios design section 4).
# Keep in sync: identical copies in shoplive_core, shoplive_flutter_sample (shoplive_player) and shoplive_streamer ios/.
#
# When the podspec is evaluated (pod install) it downloads the GitHub release XCFramework zips, verifies the
# sha256 (SDK Package.swift constants) and unpacks them into ios/Frameworks/ for vendored_frameworks.
# prepare_command does not run for path pods (Flutter plugins), hence this approach.
#
# Environment variables
#   SHOPLIVE_IOS_SDK_DIR       folder with pre-downloaded <Name>.xcframework.zip files (offline/CI); no network is used.
#   SHOPLIVE_IOS_SDK_BASE_URL  replaces the release download base URL (mirror). Default: https://github.com/shoplive/shoplive-sdk-ios/releases/download
# Proxies: curl honours HTTPS_PROXY / ALL_PROXY / NO_PROXY.
# Compatibility: must run on the macOS system Ruby 2.6 (CocoaPods installed with sudo gem) - no Ruby 2.7+ syntax.
# The frameworks must live inside the plugin directory (vendored_frameworks), so that directory must be writable.
require 'digest'
require 'fileutils'
require 'tmpdir'

module ShopliveIosSdk
  def self.default_base_url
    'https://github.com/shoplive/shoplive-sdk-ios/releases/download'
  end

  # artifacts: { 'ShopliveCore' => '<sha256>', ... }
  def self.ensure!(pod_dir:, version:, artifacts:)
    frameworks = File.join(pod_dir, 'Frameworks')
    begin
      FileUtils.mkdir_p(frameworks)
      # Cross-process exclusion (concurrent pod install on a shared pub-cache, IOS-M2). Markers are re-checked under the lock.
      File.open(File.join(frameworks, '.lock'), File::RDWR | File::CREAT, 0o644) do |lock|
        lock.flock(File::LOCK_EX)
        remove_stale_tmp(frameworks)
        artifacts.each { |name, sha256| ensure_one(frameworks, version, name, sha256) }
      end
    rescue Errno::EACCES, Errno::EPERM, Errno::EROFS => e
      fail!("cannot write #{frameworks} (#{e.class.name.split('::').last}). The SDK frameworks must be stored inside the " \
            'plugin directory. Make that directory writable, or use a writable pub cache (set PUB_CACHE to a writable ' \
            'folder and run flutter pub get), then run pod install again.')
    end
  end

  # Leftovers of an interrupted install. Safe under the lock: no other process is extracting.
  def self.remove_stale_tmp(frameworks)
    Dir.glob(File.join(frameworks, '.tmp-*')).each { |dir| FileUtils.rm_rf(dir) }
  end

  # An xcframework is usable when its Info.plist and at least one slice binary exist.
  def self.framework_complete?(xcframework, name)
    File.file?(File.join(xcframework, 'Info.plist')) &&
      !Dir.glob(File.join(xcframework, '*', "#{name}.framework", name)).empty?
  end

  def self.marker_path(frameworks, version, name)
    File.join(frameworks, ".shoplive-ios-sdk-#{version}-#{name}.ok")
  end

  def self.installed?(frameworks, version, name, sha256)
    marker = marker_path(frameworks, version, name)
    File.file?(marker) && File.read(marker).strip == sha256 &&
      framework_complete?(File.join(frameworks, "#{name}.xcframework"), name)
  end

  def self.ensure_one(frameworks, version, name, sha256)
    if installed?(frameworks, version, name, sha256)
      log("#{name} #{version}: cached (sha256 verified at install)")
      return
    end
    target = File.join(frameworks, "#{name}.xcframework")
    Dir.mktmpdir(".tmp-#{name}-", frameworks) do |tmp| # same volume, unique path -> atomic rename
      zip = obtain_zip(tmp, version, name)
      actual = Digest::SHA256.file(zip).hexdigest
      unless actual == sha256
        fail!("#{name}.xcframework.zip checksum mismatch: expected #{sha256}, actual #{actual}. " \
              'Refusing to link an unverified binary.')
      end
      fail!("failed to unzip #{zip}") unless system('ditto', '-x', '-k', zip, tmp)
      extracted = File.join(tmp, "#{name}.xcframework")
      unless framework_complete?(extracted, name)
        fail!("#{name}.xcframework in the zip is incomplete (missing Info.plist or #{name}.framework/#{name})")
      end
      FileUtils.rm_f(marker_path(frameworks, version, name))
      FileUtils.rm_rf(target)
      begin
        File.rename(extracted, target)
      rescue SystemCallError => e
        # Another install may have finished first (e.g. manual changes outside the lock); re-verify.
        return if installed?(frameworks, version, name, sha256)
        fail!("could not move #{name}.xcframework into place: #{e.message}")
      end
      File.write(marker_path(frameworks, version, name), sha256)
      log("#{name} #{version}: installed (sha256 #{sha256[0, 12]}...)")
    end
  end

  def self.obtain_zip(tmp, version, name)
    file = "#{name}.xcframework.zip"
    local_dir = ENV['SHOPLIVE_IOS_SDK_DIR']
    if local_dir && !local_dir.empty?
      local = File.join(local_dir, file)
      fail!("SHOPLIVE_IOS_SDK_DIR is set but #{local} does not exist") unless File.file?(local)
      log("#{name} #{version}: using #{local}")
      return local
    end
    base = ENV['SHOPLIVE_IOS_SDK_BASE_URL']
    base = default_base_url if base.nil? || base.empty?
    url = "#{base}/#{version}/#{file}"
    out = File.join(tmp, file)
    log("#{name} #{version}: downloading #{url}")
    ok = system('curl', '-fL', '-sS', '--retry', '3', '--connect-timeout', '20', '--max-time', '600', '-o', out, url)
    unless ok
      fail!("download failed (curl exit #{$?.exitstatus}) for #{url}. Check network/proxy, or set " \
            'SHOPLIVE_IOS_SDK_DIR to a folder with the release zips, or SHOPLIVE_IOS_SDK_BASE_URL to a mirror.')
    end
    out
  end

  def self.log(message)
    line = "[shoplive] #{message}"
    defined?(Pod::UI) ? Pod::UI.puts(line) : puts(line)
  end

  def self.fail!(message)
    raise "[shoplive] #{message}"
  end
end
