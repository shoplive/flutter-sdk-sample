#import "ShoplivePlayerPlugin.h"
#if __has_include(<shoplive_player/shoplive_player-Swift.h>)
#import <shoplive_player/shoplive_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "shoplive_player-Swift.h"
#endif

@implementation ShoplivePlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftShoplivePlayerPlugin registerWithRegistrar:registrar];
}
@end
