#import "NMCNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 클러스터 노드를 의미하는 클래스.
 */
NMF_EXPORT
@interface NMCCluster : NMCNode

/**
 태그. `NMCTagMergeStrategy.mergeTag:`로 병합한 객체.
 */
@property (nonatomic, nullable, readonly) NSObject *tag;

/**
 자식 `NMCNode`의 목록.
 */
@property (nonatomic, nonnull, readonly) NSArray<NMCNode *> *children;

/**
 전체 `NMCLeaf`의 개수.
 */
@property (nonatomic, assign, readonly) NSInteger size;

/**
 웹 메르카토르 좌표.
 */
@property (nonatomic, nonnull, readonly) NMGWebMercatorCoord *coord;

/**
 좌표. `NMCPositioningStrategy.getPosition:`으로 구한 웹 메르카토르 좌표를
 `NMGLatLng`으로 변환한 좌표.
 */
@property (nonatomic, nonnull, readonly) NMGLatLng *position;

@end

NS_ASSUME_NONNULL_END
