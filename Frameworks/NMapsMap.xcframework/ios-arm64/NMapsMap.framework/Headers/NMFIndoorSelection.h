#import "NMFFoundation.h"

@class NMFIndoorRegion;
@class NMFIndoorZone;
@class NMFIndoorLevel;

/**
 하나의 실내지도 영역 내에서 선택된 구역 및 층을 나타내는 불변 클래스.
 */
NMF_EXPORT
@interface NMFIndoorSelection : NSObject

/**
 선택된 구역의 영역.
 */
@property(nonatomic, readonly, nonnull) NMFIndoorRegion *region;

/**
 선택된 구역의 인덱스.
 */
@property(nonatomic, readonly) NSInteger zoneIndex;

/**
 선택된 구역.
 */
@property(nonatomic, readonly, nonnull) NMFIndoorZone *zone;

/**
 선택된 층의 인덱스.
 */
@property(nonatomic, readonly) NSInteger levelIndex;

/**
 선택된 층.
 */
@property(nonatomic, readonly, nonnull) NMFIndoorLevel *level;

/**
 실내지도 영역 객체와 선택된 구역의 인덱스 및 층의 인덱스를 사용하는 생성자.
 
 @param region 실내지도 영역.
 @param zoneIndex 선택된 구역의 인덱스.
 @param levelIndex 선택된 층의 인덱스.
 */
+(instancetype _Nonnull)indoorSelectionWithRegion:(NMFIndoorRegion * _Nonnull)region
                                        ZoneIndex:(NSInteger)zoneIndex
                                       LevelIndex:(NSInteger)levelIndex;

@end
