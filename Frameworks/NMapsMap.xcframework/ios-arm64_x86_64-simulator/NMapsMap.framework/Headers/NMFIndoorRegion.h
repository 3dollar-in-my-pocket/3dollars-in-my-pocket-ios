#import "NMFFoundation.h"

NS_ASSUME_NONNULL_BEGIN

@class NMFIndoorZone;

/**
 실내지도가 존재하는 영역을 나타내는 불변 클래스. 하나의 실내지도 영역은 서로 겹쳐진 한 개 이상의 구역으로 이루어집니다.
 이 클래스의 인스턴스는 직접 생성할 수 없습니다.
 */
NMF_EXPORT
@interface NMFIndoorRegion : NSObject

/**
 영역에 속해 있는 구역 목록
 */
@property(nonatomic, readonly) NSArray<NMFIndoorZone *> *zones;

+ (NMFIndoorRegion *)indoorRegion:(NSArray<NMFIndoorZone *> *)zones;

/**
 영역에 속해 있는 구역 중 ID가 `zoneId`인 구역의 인덱스를 반환합니다.
 
 @param zoneId 구역 ID.
 @return 구역의 인덱스. 영역 내에 ID가 `zoneId`인 구역이 없을 경우 `-1`.
 */
- (NSInteger)getZoneIndex:(NSString *)zoneId;

/**
 영역에 속해 있는 구역 중 ID가 `zoneId`인 구역을 반환합니다.
 
 @param zoneId 구역 ID.
 @return 구역 객체. 영역 내에 ID가 `zoneId`인 구역이 없을 경우 `nil`.
 */
- (NMFIndoorZone *_Nullable)getZone:(NSString *)zoneId;

@end
NS_ASSUME_NONNULL_END
