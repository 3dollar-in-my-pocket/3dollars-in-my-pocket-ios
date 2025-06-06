#import "NMCMarkerInfo.h"

@class NMGLatLng;

NS_ASSUME_NONNULL_BEGIN

/**
 지도에 노출되어야 하는 클러스터 마커의 속성을 나타내는 클래스.
 */
NMF_EXPORT
@interface NMCClusterMarkerInfo : NMCMarkerInfo

/**
 태그. `NMCTagMergeStrategy.mergeTag:`로 병합한 객체.
 */
@property (nonatomic, nullable, readonly) NSObject *tag;

/**
 좌표. `NMCPositioningStrategy.getPosition:`으로 구한 웹 메르카토르 좌표를
 `NMGLatLng`으로 변환한 좌표.
 */
@property (nonatomic, nonnull, readonly) NMGLatLng *position;

/**
 전체 자식 단말 마커의 개수.
 */
@property (nonatomic, assign, readonly) NSInteger size;

@end

NS_ASSUME_NONNULL_END
