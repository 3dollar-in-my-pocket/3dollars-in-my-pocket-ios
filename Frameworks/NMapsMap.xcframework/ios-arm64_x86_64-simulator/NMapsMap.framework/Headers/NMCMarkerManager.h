#import "NMFFoundation.h"

@class NMCMarkerInfo;
@class NMFMarker;

NS_ASSUME_NONNULL_BEGIN

/**
 `NMCClusterer`에서 노출하는 마커 객체를 관리하는 인터페이스.
 
 마커가 지도에 처음 노출되면 `retainMarker:` 메서드가 호출되며, 더 이상 노출되지 않으면
 `releaseMarker:` 메서드가 호출됩니다.
 
 @see `NMCComplexBuilder.markerManager`
 */
NMF_EXPORT
@protocol NMCMarkerManager

/**
 `info`를 노출할 마커 객체를 반환합니다.
 
 @param info 노출이 필요한 `NMCMarkerInfo` 객체.
 @return 노출할 `NMFMarker` 객체
 */
- (NMFMarker * _Nullable)retainMarker:(NMCMarkerInfo * _Nonnull)info;

/**
 더 이상 노출되지 않는 `info`의 `marker`를 정리합니다.
 
 @param info 더 이상 노출되지 않는 `NMCMarkerInfo` 객체.
 @param marker 더 이상 노출되지 않는 `NMFMarker` 객체.
 */
- (void)releaseMarker:(NMCMarkerInfo * _Nonnull)info :(NMFMarker * _Nonnull)marker;

@end

NS_ASSUME_NONNULL_END
