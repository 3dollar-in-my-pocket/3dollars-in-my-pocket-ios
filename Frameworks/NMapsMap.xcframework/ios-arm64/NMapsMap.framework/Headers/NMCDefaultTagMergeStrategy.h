#import "NMCTagMergeStrategy.h"

@class NMCCluster;

NS_ASSUME_NONNULL_BEGIN

/**
 기본 `NMCDefaultTagMergeStrategy` 구현체. 태그를 병합하지 않고 버립니다.
 */
NMF_EXPORT
@interface NMCDefaultTagMergeStrategy : NSObject<NMCTagMergeStrategy>

/**
 `cluster`에 속한 자식 `NMCNode`의 태그를 사용하지 않고 항상 `nil`을 반환합니다.
 
 @param cluster 태그를 병합할 `cluster` 객체.
 @return 병합된 `cluster`의 태그.
 */
- (NSObject * _Nullable)mergeTag:(NMCCluster * _Nonnull)cluster;

@end

NS_ASSUME_NONNULL_END
