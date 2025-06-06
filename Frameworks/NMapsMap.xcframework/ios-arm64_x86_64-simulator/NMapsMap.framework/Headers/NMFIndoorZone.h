#import "NMFFoundation.h"

@class NMFIndoorLevel;

NS_ASSUME_NONNULL_BEGIN

/**
 하나의 실내지도 구역을 나타내는 불변 클래스. 하나의 실내지도 구역에는 한 개 이상의 층이 있습니다. 이 클래스의
 인스턴스는 직접 생성할 수 없고 `NMFIndoorRegion`을 이용해서 가져올 수 있습니다.
 
 @see `NMFIndoorRegion`
 */
NMF_EXPORT
@interface NMFIndoorZone : NSObject

/**
 구역 ID.
 */
@property(nonatomic, readonly) NSString *zoneId;

/**
 대표 층의 인덱스.
 */
@property(nonatomic, readonly) NSInteger defaultLevelIndex;

/**
 층 목록.
 */
@property(nonatomic, readonly) NSArray<NMFIndoorLevel *> *levels;

@property(nonatomic, readonly) NSUInteger hash;

+ (NMFIndoorZone *)indoorZone:(NSString *)zoneId
            defaultLevelIndex:(NSInteger)defaultLevelIndex
                       Levels:(NSArray<NMFIndoorLevel *> *)levels;

/**
 구역에 속한 층 중 ID가 `levelId`인 층의 인덱스를 반환합니다.
 
 @param levelId 층 ID.
 @return 층의 인덱스. 구역 내에 ID가 `levelId`인 층이 없을 경우 `-1`.
 */
- (NSInteger)getLevelIndex:(NSString *)levelId;

/**
 구역에 속한 층 중 ID가 `levelId`인 층을 반환합니다.
 
 @param levelId 층 ID.
 @return 층 객체. 구역 내에 ID가 `levelId`인 층이 없을 경우 `nil`.
 */
- (NMFIndoorLevel *_Nullable)getLevel:(NSString *)levelId;

/**
 대표 층을 반환합니다.
 
 @return 대표 층.
 */
- (NMFIndoorLevel *_Nonnull)getDefaultLevel;

@end
NS_ASSUME_NONNULL_END
