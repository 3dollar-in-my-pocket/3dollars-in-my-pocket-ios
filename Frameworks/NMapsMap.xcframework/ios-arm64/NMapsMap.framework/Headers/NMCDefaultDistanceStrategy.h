#import "NMCDistanceStrategy.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `NMCDistanceStrategy` 구현체. 두 `NMCNode`간의 화면상 거리를 측정합니다.
 */
NMF_EXPORT
@interface NMCDefaultDistanceStrategy : NSObject<NMCDistanceStrategy>

/**
 줌 레벨이 `zoom`일 때 `node1`과 `node2`간의 거리를 반환합니다.
 
 @param zoom 거리를 측정할 줌 레벨.
 @param node1 거리를 측정할 첫 번째 `NMCNode` 객체.
 @param node2 거리를 측정할 두 번째 `NMCNode` 객체.
 @return `node1`과 `node2`간의 화면상 거리.
 */
- (double)getDistance:(NSInteger)zoom Node1:(NMCNode * _Nonnull)node1 Node2:(NMCNode * _Nonnull)node2;

@end

NS_ASSUME_NONNULL_END
