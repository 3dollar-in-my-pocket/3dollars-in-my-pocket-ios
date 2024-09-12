#import "NMFFoundation.h"

@class NMCNode;

NS_ASSUME_NONNULL_BEGIN

/**
 각 `NMCNode`간의 거리를 측정하는 전략에 대한 인터페이스.
 
 이 전략은 `NMCThresholdStrategy`와 밀접하게 연관되어 있습니다. 두 노드 `node1`, `node2`가
 있을 때, `getDistance:Node1:Node2`가 반환한 둘 간의 거리가 `NMCThresholdStrategy.getThreshold`가
 반환한 기준값보다 작거나 같으면 두 노드는 <code>zoom</code> 레벨에서 클러스터링됩니다.
 
 @see `NMCComplexBuilder.distanceStrategy`
 @see `NMCComplexBuilder.thresholdStrategy`
 @see `NMCThresholdStrategy.getThreshold:`
 */
NMF_EXPORT
@protocol NMCDistanceStrategy

/**
 줌 레벨이 `zoom`일 때 `node1`과 `node2`간의 거리를 반환합니다.
 
 @param zoom 거리를 측정할 줌 레벨.
 @param node1 거리를 측정할 첫 번째 `NMCNode` 객체.
 @param node2 거리를 측정할 두 번째 `NMCNode` 객체.
 @return `node1`과 `node2`간의 거리.
 */
- (double)getDistance:(NSInteger)zoom Node1:(NMCNode * _Nonnull)node1 Node2:(NMCNode * _Nonnull)node2;

@end

NS_ASSUME_NONNULL_END
