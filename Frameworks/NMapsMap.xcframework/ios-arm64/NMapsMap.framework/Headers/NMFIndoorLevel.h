#import "NMFIndoorView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 하나의 실내지도 층을 나타내는 불변 클래스. 하나의 실내지도 층은 다른 층과 연결될 수 있습니다. 이 클래스의 인스턴스는
 직접 생성할 수 없고 `NMFIndoorZone`을 이용해서 가져올 수 있습니다.
 
 @see `NMFIndoorZone`
 */
NMF_EXPORT
@interface NMFIndoorLevel : NSObject

/**
 층에 해당하는 실내지도 뷰.
 */
@property(nonatomic, readonly) NMFIndoorView *_Nonnull indoorView;

/**
 층의 명칭.
 */
@property(nonatomic, readonly) NSString *_Nonnull name;

/**
 연결된 층의 실내지도 뷰 목록.
 */
@property(nonatomic, readonly) NSArray<NMFIndoorView *> *_Nonnull connections;

+ (NMFIndoorLevel *_Nonnull)indoorLevel:(NSString *_Nonnull)zoneId
                                LevelId:(NSString *_Nonnull)levelId
                                   Name:(NSString *_Nonnull)name
                            Connections:(NSArray<NMFIndoorView *> *_Nonnull)connections;

/**
 연결된 층 중 구역 ID가 `zoneId`인 실내지도 뷰의 인덱스를 반환합니다.
 
 @param zoneId 구역 ID.
 @return 실내지도 뷰의 인덱스. 연결된 층 중에 ID가 `zoneId`인 층이 없을 경우 `-1`.
 */
- (NSInteger)getConnectionIndex:(NSString *_Nonnull)zoneId;

/**
 연결된 층 중 구역 ID가 `zoneId`인 실내지도 뷰를 반환합니다.
 
 @param zoneId 구역 ID.
 @return 실내지도 뷰. 연결된 층 중에 ID가 `zoneId`인 층이 없을 경우 `nil`.
 */
- (NMFIndoorView *_Nullable)getConnection:(NSString *_Nonnull)zoneId;

@end
NS_ASSUME_NONNULL_END
