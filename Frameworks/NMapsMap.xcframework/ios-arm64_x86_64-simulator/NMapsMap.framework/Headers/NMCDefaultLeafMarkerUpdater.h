#import "NMCLeafMarkerUpdater.h"

NS_ASSUME_NONNULL_BEGIN

/**
 기본 `NMCLeafMarkerUpdater` 구현체. `NMFMarker`의 다음과 같은 속성을 지정합니다.
 <ul>
 <li>아이콘(`NMFMarker.iconImage`): `NMF_MARKER_IMAGE_DEFAULT`로 지정됩니다.</li>
 <li>앵커(`NMFMarker.anchor`): `CGPointMake(0.5, 1.0)`로 지정됩니다.</li>
 <li>캡션 텍스트(`NMFMarker.captionText`): 빈 문자열(`""`)로 지정됩니다.</li>
 <li>캡션 정렬 방향(`NMFMarker.captionAligns`): `NMFAlignType.bottom`로 지정됩니다.</li>
 <li>캡션 색상(`NMFMarker.captionColor`): `UIColor.blackColor`로 지정됩니다.</li>
 <li>캡션 외곽 색상(`NMFMarker.captionHaloColor`): `UIColor.whiteColor`로 지정됩니다.</li>
 <li>마커 클릭 시 동작(`NMFMarker.touchHandler`): `nil`로 지정되어 아무런 동작도 하지 않습니다.</li>
 </ul>
 */
NMF_EXPORT
@interface NMCDefaultLeafMarkerUpdater : NSObject<NMCLeafMarkerUpdater>

/**
 `info`의 정보를 `marker`의 속성에 반영합니다.
 
 @param info 단말 마커의 정보.
 @param marker 단말 마커의 정보를 포현할 `NMFMarker` 객체.
 */
- (void)updateLeafMarker:(NMCLeafMarkerInfo * _Nonnull)info :(NMFMarker * _Nonnull)marker;

@end

NS_ASSUME_NONNULL_END
