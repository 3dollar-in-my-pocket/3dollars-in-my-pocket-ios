#import "NMFFoundation.h"
#import "NMCMarkerManager.h"

/**
 기본 재사용 풀 크기.
 */
const static double NMC_DEFAULT_MAX_POOL_SIZE = 200;

NS_ASSUME_NONNULL_BEGIN

/**
 기본 `NMCMarkerManager` 구현체. 이 클래스를 이용하면 `NMFMarker` 객체가 재사용되어 성능이 향상됩니다. 대신 한
 번 사용되었던 `NMFMarker` 객체의 속성이 초기화되지 않고 계속 남으므로 `NMCClusterMarkerUpdater`와
 `NMCLeafMarkerUpdater`에서 매번 `NMFMarker`의 속성을 지정해야 합니다. 단, 변하지 않는 속성이 있다면
 `createMarker:`를 오버라이드해 `NMFMarker`의 속성을 생성 직후 한 번만 지정하도록 최적화할 수 있습니다.
 */
@interface NMCDefaultMarkerManager : NSObject<NMCMarkerManager>

/**
 기본 생성자. 재사용 풀의 크기는 `NMC_DEFAULT_MAX_POOL_SIZE`로 지정됩니다.
 */
- (instancetype)init;

/**
 재사용 풀의 크기를 지정하는 생성자.
 
 @param maxPoolSize 재사용 풀의 크기.
 */
- (instancetype)initWithMaxPoolSize:(NSInteger)maxPoolSize;

/**
 풀로부터 `NMCMarker` 객체를 가져와 반환합니다. 풀이 비어있다면 `createMarker:`를 호출해 새로운 마커
 객체를 생성합니다.
 */
- (NMFMarker * _Nonnull)retainMarker:(NMCMarkerInfo * _Nonnull)info;

/**
 `NMFMarker` 객체를 다시 사용할 수 있도록 풀로 반환합니다.
 */
- (void)releaseMarker:(NMCMarkerInfo * _Nonnull)info :(NMFMarker * _Nonnull)marker;

/**
 새로운 마커 객체를 생성합니다.
 */
- (NMFMarker * _Nonnull)createMarker;

@end

NS_ASSUME_NONNULL_END
