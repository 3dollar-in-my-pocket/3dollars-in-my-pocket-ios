#import "NMFFoundation.h"

@class NMCClusterMarkerInfo;
@class NMFMarker;

NS_ASSUME_NONNULL_BEGIN

/**
 단말 마커의 정보를 `NMFMarker`의 속성에 반영해 갱신하는 델리게이트.
 
 단말 마커가 지도에 처음 노출되거나 정보가 변경되면 `updateClusterMarker::` 메서드가 호출되며,
 이 메서드로 전달되는 `NMFMarker`가 화면에 노출됩니다. 따라서 이 메서드 내에서 `NMCClusterMarkerInfo`의
 정보를 가져와 `NMFMarker`의 속성에 적절하게 반영하도록 구현해야 합니다. 단, `NMFMarker`의
 `NMFMarker.position` 및 `NMFMarker.mapView` 속성은 자동으로 관리되므로 별도로
 반영할 필요가 없습니다.
 
 @see `NMCBuilder.clusterMarkerUpdater`
 @see `NMCComplexBuilder.clusterMarkerUpdater`
 */
NMF_EXPORT
@protocol NMCClusterMarkerUpdater

/**
 `info`의 정보를 `marker`의 속성에 반영합니다.
 
 @param info 클러스터 마커의 정보.
 @param marker 클러스터 마커의 정보를 포현할 `NMFMarker` 객체.
 */
- (void)updateClusterMarker:(NMCClusterMarkerInfo * _Nonnull)info :(NMFMarker * _Nonnull)marker;

@end

NS_ASSUME_NONNULL_END
