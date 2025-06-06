#import "NMCThresholdStrategy.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 기본 `NMCThresholdStrategy` 구현체. 고정된 기준 거리를 사용합니다.
 */
NMF_EXPORT
@interface NMCDefaultThresholdStrategy : NSObject<NMCThresholdStrategy>

/**
 생성자.
 
 @param threshold 기준 거리.
 */
- (instancetype)initWithThreshold:(double)threshold;

/**
 생성자로 지정된 `threshold`를 반환합니다.
 
 @param zoom 기준 거리를 구할 줌 레벨.
 @return 클러스터링할 기준 거리.
 */
- (double)getThreshold:(NSInteger)zoom;

@end

NS_ASSUME_NONNULL_END
