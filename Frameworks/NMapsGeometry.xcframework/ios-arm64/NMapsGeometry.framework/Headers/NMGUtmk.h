#import "NMGGeometry.h"

@class NMGLatLng;
@class NMGLatLngBounds;

/**
 커버리지 내 `x`의 최솟값.
 */
const static double NMG_UTMK_MINIMUM_X = 283038.5;

/**
 커버리지 내 `y`의 최솟값.
 */
const static double NMG_UTMK_MINIMUM_Y = 1248041.6;

/**
 커버리지 내 `x`의 최댓값.
 */
const static double NMG_UTMK_MAXIMUM_X = 1937760.8;

/**
 커버리지 내 `y`의 최댓값.
 */
const static double NMG_UTMK_MAXIMUM_Y = 2619635;

/**
 UTMK 좌표를 표현하는 클래스.
 */
NMG_EXPORT
@interface NMGUtmk : NSObject <NMGPointable>

/**
 x 좌표.
 */
@property (nonatomic, readonly) double x;

/**
 y 좌표.
 */
@property (nonatomic, readonly) double y;

/**
 UTM-K 좌표로 나타낼 수 있는 범위를 리턴합니다.
 southWest(31.0, 120.0)
 northEast(43.0, 139.0)
 
 @return NMGLatLngBounds 객체
 */
+ (nonnull NMGLatLngBounds *)coverage;

/**
 지정한 위치에 대한 좌표를 생성합니다.
 
 @return NMGUtmk 객체
 */
+ (nonnull instancetype)utmk;

/**
 지정한 위치에 대한 좌표를 생성합니다.
 
 @param x 좌표
 @param y 좌표
 @return NMGUtmk 객체
 */
+ (nonnull instancetype)utmkWithX:(double)x y:(double)y;

/**
 위경도 좌표를 UTM-K 좌표로 변환합니다.
 
 @param latLng 위경도 좌표
 @return NMGUtmk 객체
 */
+ (nonnull instancetype)utmkFromLatLng:(nonnull NMGLatLng *)latLng;

/**
 좌표를 위경도 좌표로 변환합니다.
 
 @return 변환된 위경도 좌표.
 */
- (nonnull NMGLatLng *)toLatLng;

/**
 좌표가 좌표계의 커버리지 내에 포함되는지 여부를 반환합니다. 커버리지를 벗어날 경우 좌표 연산의 정확도가 보장되지
 않습니다.
 
 @return 커버리지 내일 경우 `YES`, 그렇지 않을 경우 `NO`.
 */
- (BOOL)isWithinCoverage;

@end

static inline NMGUtmk * _Nonnull NMGUtmkMake(double x, double y) NS_SWIFT_UNAVAILABLE("Not use in swift.") {
    return [NMGUtmk utmkWithX:x y:y];
}
