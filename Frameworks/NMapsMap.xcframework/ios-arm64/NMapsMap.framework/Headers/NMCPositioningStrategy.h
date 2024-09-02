#import "NMFFoundation.h"

@class NMGWebMercatorCoord;
@class NMCCluster;

NS_ASSUME_NONNULL_BEGIN

/**
 한 `cluster`의 좌표를 정하는 전략에 대한 인터페이스.
 
 `NMCNode`가 하나의 `NMCCluster`를 이루거나, 한 `NMCCluster`의 자식 노드가 변경되면
 `getPosition:` 메서드가 호출되며, 이 메서드에서 반환한 값이 이 `NMCCluster`의 좌표가 됩니다.
 따라서 이 메서드 내에서 `NMCCluster.tag` 또는 `NMCCluster.children`을 호출해 태그나 자식 노드의
 좌표 등 정보를 가져와 적절한 좌표를 반환하도록 구현해야 합니다.
 */
NMF_EXPORT
@protocol NMCPositioningStrategy

/**
 `cluster`의 좌표를 반환합니다.
 
 @param cluster 좌표를 구해야 하는 `cluster` 객체.
 @return 웹 메르카토르 좌표.
 */
- (NMGWebMercatorCoord * _Nonnull)getPosition:(NMCCluster * _Nonnull)cluster;

@end

NS_ASSUME_NONNULL_END
