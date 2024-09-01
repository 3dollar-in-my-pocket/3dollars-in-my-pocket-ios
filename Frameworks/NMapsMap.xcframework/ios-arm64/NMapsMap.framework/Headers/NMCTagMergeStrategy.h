#import "NMFFoundation.h"

@class NMCCluster;

NS_ASSUME_NONNULL_BEGIN

/**
 부모 `NMCCluster`의 자식 `NMCNode`들의 태그를 병합하는 전략에 대한 인터페이스.
 
 여러 `NMCNode`가 하나의 `NMCCluster`로 합쳐지면 `mergeTag:` 메서드가 호출되며, 이 메서드에서
 반환한 값이 부모 `NMCCluster`의 태그가 됩니다. 따라서 이 메서드 내에서 `NMCCluster.children`을 호출해
 자식 `NMCNode`의 태그를 순회하고 병합해 반환하도록 구현해야 합니다.
 
 @see `NMCComplexBuilder.tagMergeStrategy`
 */
NMF_EXPORT
@protocol NMCTagMergeStrategy

/**
 `NMCCluster`에 속한 `NMCNode`의 태그를 병합해 반환합니다.
 
 @param cluster 태그를 병합할 `cluster` 객체.
 @return 병합된 `cluster`의 태그.
 */
- (NSObject * _Nullable)mergeTag:(NMCCluster * _Nonnull)cluster;

@end

NS_ASSUME_NONNULL_END
