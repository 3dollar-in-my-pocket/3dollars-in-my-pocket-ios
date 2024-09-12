#import "NMCMarkerInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NMCClusteringKey;

/**
 지도에 노출되어야 하는 단말 마커의 속성을 나타내는 클래스.
 */
NMF_EXPORT
@interface NMCLeafMarkerInfo : NMCMarkerInfo

/**
 키. `NMCClusterer.add:Tag:`로 지정한 `key`.
 */
@property (nonatomic, nonnull, readonly) id<NMCClusteringKey> key;

/**
 태그. `NMCClusterer.add:Tag:`로 지정한 `tag`.
 */
@property (nonatomic, nullable, readonly) NSObject *tag;

/**
 좌표. `NMCClusterer.add:Tag:`로 지정한 `NMCClusteringKey.position`.
 */
@property (nonatomic, nonnull, readonly) NMGLatLng *position;

@end

NS_ASSUME_NONNULL_END
