#import "NMFFoundation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 두 `NMCNode`를 클러스터링할 기준 거리를 구하는 전략에 대한 인터페이스.
 
 이 전략은`NMCDistanceStrategy`와 밀접하게 연관되어 있습니다. 두 노드 `node1`, `node2`가
 있을 때, `NMCDistanceStrategy.getDistance:Node1:Node2`가 반환한 둘 간의 거리가 `getThreshold:`가
 반환한 기준 거리보다 작거나 같으면 두 노드는`zoom` 레벨에서 클러스터링됩니다.
 
 @see `NMCComplexBuilder.distanceStrategy`
 @see `NMCComplexBuilder.thresholdStrategy`
 @see `NMCThresholdStrategy.getThreshold:`
 */
NMF_EXPORT
@protocol NMCThresholdStrategy

/**
 줌 레벨이 `zoom`일 때 두 `NMCNode`를 클러스터링할 기준 거리를 반환합니다.
 
 @param zoom 기준 거리를 구할 줌 레벨.
 @return 클러스터링할 기준 거리.
 */
- (double)getThreshold:(NSInteger)zoom;

@end

NS_ASSUME_NONNULL_END
