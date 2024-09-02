#import "NMCNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 단말 노드를 의미하는 클래스.
 */
NMF_EXPORT
@interface NMCLeaf : NMCNode

/**
 키. `NMCClusterer.add:Tag:`로 지정한 `key`가 반환됩니다.
 */
@property (nonatomic, nonnull, readonly) NSObject *key;

/**
 태그. `NMCClusterer.add:Tag:`로 지정한 `tag`가 반환됩니다.
 */
@property (nonatomic, nullable, readonly) NSObject *tag;

/**
 자식 노드의 개수. 항상 `1`이 반환됩니다.
 */
@property (nonatomic, assign, readonly) NSInteger size;

/**
 웹 메르카토르 좌표.
 */
@property (nonatomic, nonnull, readonly) NMGWebMercatorCoord *coord;

/**
 좌표. `NMCClusterer.add:Tag:`로 지정한 `NMCClusteringKey.position`이 반환됩니다.
 */
@property (nonatomic, nonnull, readonly) NMGLatLng *position;

@end

NS_ASSUME_NONNULL_END
