# shoplive_core 플러그인 consumer rules (호스트 앱 R8에 적용)
# Shoplive core 3.0.2 AAR의 내부 클래스(cloud.shoplive.core.internal.common.ShopLiveCommonAuth 등)가
# @kotlinx.parcelize.Parcelize를 참조하지만 AAR consumer proguard.txt에 대응 규칙이 없어 release R8이 Missing class로 실패한다.
# Parcelize는 BINARY 보존 애너테이션(런타임 불필요)이므로 경고만 억제한다.
-dontwarn kotlinx.parcelize.Parcelize
