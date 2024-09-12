#import "NMGGeometry.h"

@class NMGLatLng;
@class NMGLatLngBounds;

/**
 커버리지 내 `x`의 최솟값.
 */
const static double NMG_TM128_MINIMUM_X = 30408.747066328477;

/**
 커버리지 내 `y`의 최솟값.
 */
const static double NMG_TM128_MINIMUM_Y = 158674.67403835512;

/**
 커버리지 내 `x`의 최댓값.
 */
const static double NMG_TM128_MAXIMUM_X = 749976.0946343569;

/**
 커버리지 내 `y`의 최댓값.
 */
const static double NMG_TM128_MAXIMUM_Y = 643904.8888573726;

/**
 TM-128 좌표를 표현하는 클래스.
 */
NMG_EXPORT
@interface NMGTm128 : NSObject <NMGPointable>

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
 southWest(33.96, 124.0)
 northEast(38.33, 132.0)
 
 @return NMGLatLngBounds 객체
 */
+ (nonnull NMGLatLngBounds *)coverage;

/**
 지정한 위치에 대한 좌표를 생성합니다.
 
 @return NMGUtmk 객체
 */
+ (nonnull instancetype)tm128;

/**
 지정한 위치에 대한 좌표를 생성합니다.
 
 @param x 좌표
 @param y 좌표
 @return NMGTm128 객체
 */
+ (nonnull instancetype)tm128WithX:(double)x y:(double)y;

/**
 위경도 좌표를 UTM-K 좌표로 변환합니다.
 
 @param latLng 위경도 좌표
 @return NMGTm128 객체
 */
+ (nonnull instancetype)tm128FromLatLng:(nonnull NMGLatLng *)latLng;

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

static inline NMGTm128 * _Nonnull NMGTm128Make(double x, double y) NS_SWIFT_UNAVAILABLE("Not use in swift.") {
    return [NMGTm128 tm128WithX:x y:y];
}
