#import "NMCPositioningStrategy.h"

@class NMCCluster;
@class NMGWebMercatorCoord;

NS_ASSUME_NONNULL_BEGIN

/**
 기본 `NMCDefaultPositioningStrategy` 구현체. 자식 노드의 좌표의 무게 중심을 구합니다.
 */
NMF_EXPORT
@interface NMCDefaultPositioningStrategy : NSObject<NMCPositioningStrategy>

/**
 `cluster`에 속한 자식 `NMCNode`의 무게 중심 좌표를 반환합니다.
 
 @param cluster 좌표를 구해야 하는 `cluster` 객체.
 @return 웹 메르카토르 좌표.
 */
- (NMGWebMercatorCoord * _Nonnull)getPosition:(NMCCluster * _Nonnull)cluster;

@end

NS_ASSUME_NONNULL_END
