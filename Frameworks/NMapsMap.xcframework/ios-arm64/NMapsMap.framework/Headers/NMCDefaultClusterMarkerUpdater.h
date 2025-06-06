#import "NMCClusterMarkerUpdater.h"

NS_ASSUME_NONNULL_BEGIN

/**
 클러스터 마커의 기본 앵커. 가운데를 가리킵니다.
 */
extern const NMF_EXPORT CGPoint NMF_CLUSTER_ANCHOR_DEFAULT;

/**
 기본 `NMCClusterMarkerUpdater` 구현체. `NMFMarker`의 다음과 같은 속성을 지정합니다.
 <ul>
 <li>
    아이콘(`NMFMarker.iconImage`): 클러스터의 크기(`NMCClusterMarkerInfo.size`)에 따라
    `NMF_MARKER_IMAGE_CLUSTER_LOW_DENSITY`, `NMF_MARKER_IMAGE_CLUSTER_MEDIUM_DENSITY`,
    `NMF_MARKER_IMAGE_CLUSTER_HIGH_DENSITY` 중 하나로 지정됩니다.
 </li>
 <li>앵커(`NMFMarker.anchor`): `CGPointMake(0.5, 0.5)`로 지정됩니다.</li>
 <li>캡션 텍스트(`NMFMarker.captionText`): 클러스터의 크기(`NMCClusterMarkerInfo.size`)로 지정됩니다.</li>
 <li>캡션 정렬 방향(`NMFMarker.captionAligns`): `NMFAlignType.center`로 지정됩니다.</li>
 <li>캡션 색상(`NMFMarker.captionColor`): `UIColor.whiteColor`로 지정됩니다.</li>
 <li>캡션 외곽 색상(`NMFMarker.captionHaloColor`): `UIColor.clearColor`로 지정됩니다.</li>
 <li>
    마커 클릭 시 동작(`NMFMarker.touchHandler`): 클러스터가 펼쳐지는 최소 줌 레벨로 카메라를 확대하는 동작으로 지정됩니다.
 </li>
 </ul>
 */
NMF_EXPORT
@interface NMCDefaultClusterMarkerUpdater : NSObject<NMCClusterMarkerUpdater>

/**
 `info`의 정보를 `marker`의 속성에 반영합니다.
 
 @param info 클러스터 마커의 정보.
 @param marker 클러스터 마커의 정보를 포현할 `NMFMarker` 객체.
 */
- (void)updateClusterMarker:(NMCClusterMarkerInfo * _Nonnull)info :(NMFMarker * _Nonnull)marker;

@end

NS_ASSUME_NONNULL_END
