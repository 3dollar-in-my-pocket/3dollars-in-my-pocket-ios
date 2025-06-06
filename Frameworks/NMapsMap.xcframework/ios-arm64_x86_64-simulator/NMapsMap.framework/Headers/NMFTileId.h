#import "NMFFoundation.h"

@class NMGWebMercatorCoord;
@class NMGLatLng;
@class NMGLatLngBounds;

/**
 타일 ID를 다루는 클래스. 타일 ID는 정수 단위의 줌 레벨을 의미하는 `z` 성분, `x`축 인덱스를
 의미하는 `x` 성분, `y`축 인덱스를 의미하는 `y` 성분으로 구성되며, 각 성분을 조합한
 `long` 타입으로 표현됩니다. 이 클래스의 메서드를 사용해 `long` 타입의 타일 ID로부터 각 성분을
 추출하거나 각 성분으로부터 타일 ID를 조합할 수 있습니다.
 */
NMF_EXPORT
@interface NMFTileId : NSObject

/**
 `tileId`의 `z` 성분을 반환합니다.
 
 @param tileId 타일 ID.
 @return `z` 성분.
 */
+ (NSUInteger)z:(long)tileId;

/**
 `tileId`의 `x` 성분을 반환합니다.
 
 @param tileId 타일 ID.
 @return `x` 성분.
 */
+ (NSUInteger)x:(long)tileId;

/**
 `tileId`의 `y` 성분을 반환합니다.
 
 @param tileId 타일 ID.
 @return `y` 성분.
 */
+ (NSUInteger)y:(long)tileId;

/**
 `z`, `x`, `y` 성분을 조합한 타일 ID를 반환합니다.
 
 @param z `z` 성분.
 @param x `x` 성분.
 @param y `y` 성분.
 @return 타일 ID.
 */
+ (long)tileIdFromZ:(NSUInteger)z X:(NSUInteger)x Y:(NSUInteger)y;

/**
 `coord` 좌표가 위치한 곳의 `z` 레벨 타일 ID를 반환합니다.
 
 @param z 줌 레벨.
 @param coord 좌표.
 @return 타일 ID.
 */
+ (long)tileIdFromZ:(NSUInteger)z WithCoord:(NMGWebMercatorCoord * _Nonnull)coord;

/**
 `latLng` 좌표가 위치한 곳의 `z` 레벨 타일 ID를 반환합니다.
 
 @param z 줌 레벨.
 @param latLng 좌표.
 @return 타일 ID.
 */
+ (long)tileIdFromZ:(NSUInteger)z WithLatLng:(NMGLatLng * _Nonnull)latLng;

/**
 `tileId` 타일의 영역을 반환합니다.
 
 @param tileId 타일 ID.
 @return 영역.
 */
+ (NMGLatLngBounds * _Nonnull)toLatLngBoundsFromTileId:(long)tileId;

/**
 `z`, `x`, `y` 성분을 조합한 타일의 영역을 반환합니다.
 
 @param z `z` 성분.
 @param x `x` 성분.
 @param y `y` 성분.
 @return 영역.
 */
+ (NMGLatLngBounds * _Nonnull)toLatLngBoundsFromZ:(NSUInteger)z X:(NSUInteger)x Y:(NSUInteger)y;

@end
