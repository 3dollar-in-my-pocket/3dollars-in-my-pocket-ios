#import "NMGGeometry.h"
#import "NMGConstants.h"

@class NMGLatLng;
@class NMGLatLngBounds;

/**
 커버리지 내 `x` 및 `y`의 최솟값.
 */
const static double NMG_WEB_MERCATOR_MINIMUM_XY = -M_PI * NMG_EARTH_RADIUS;

/**
 커버리지 내 `x` 및 `y`의 최댓값.
 */
const static double NMG_WEB_MERCATOR_MAXIMUM_XY = M_PI * NMG_EARTH_RADIUS;

/**
 웹 메르카토르 좌표로 나타낼 수 있는 최소 위도.
 */
const static double NMG_WEB_MERCATOR_MINIMUM_LATITUDE = -85.05112877980659;

/**
 웹 메르카토르 좌표로 나타낼 수 있는 최대 위도.
 */
const static double NMG_WEB_MERCATOR_MAXIMUM_LATITUDE = 85.05112877980659;

/**
 웹 메르카토르 좌표를 표현하는 클래스.
 */
NMG_EXPORT
@interface NMGWebMercatorCoord : NSObject <NMGPointable>

/**
 x 좌표.
 */
@property (nonatomic, readonly) double x;

/**
 y 좌표.
 */
@property (nonatomic, readonly) double y;

/**
 웹 메르카토르 좌표로 나타낼 수 있는 커버리지 영역.
 
 @return `NMGLatLngBounds` 객체.
 */
+ (nonnull NMGLatLngBounds *)coverage;

/**
 지정한 위치에 대한 좌표를 생성합니다.
 
 @return 웹 메르카토르 좌표.
 */
+ (nonnull instancetype)webMercatorCoord;

/**
 지정한 위치에 대한 좌표를 생성합니다.
 
 @param x 좌표.
 @param y 좌표.
 @return 웹 메르카토르 좌표.
 */
+ (nonnull instancetype)coordWithX:(double)x y:(double)y;

/**
 위경도 좌표를 웹 메르카토르 좌표로 변환합니다.
 
 @param latLng 위경도 좌표.
 @return 웹 메르카토르 좌표.
 */
+ (nonnull instancetype)coordFromLatLng:(nonnull NMGLatLng *)latLng;

/**
 웹 메르카토르 좌표를 위경도 좌표로 변환합니다.
 
 @return 위경도 좌표.
 */
- (nonnull NMGLatLng *)toLatLng;

/**
 좌표가 좌표계의 커버리지 내에 포함되는지 여부를 반환합니다. 커버리지를 벗어날 경우 좌표 연산의 정확도가 보장되지
 않습니다.
 
 @return 커버리지 내일 경우 `YES`, 그렇지 않을 경우 `NO`.
 */
- (BOOL)isWithinCoverage;

/**
 다른 좌표와의 거리를 구합니다. `NMGWebMercatorCoord` 좌표는 메르카토르 도법을 사용하므로 오차가 클 수
 있습니다. 지리적으로 보다 정밀한 값이 필요한 경우 `LatLng#distanceTo(LatLng)`를 사용하십시오.
 
 @param other 다른 좌표.
 @return 거리. 미터 단위.
 @see `NMGLatLng` `-distanceTo:(NMGLatLng *)`
 */
- (double)distanceTo:(nonnull NMGWebMercatorCoord *)other;

/**
 다른 좌표와의 거리의 제곱을 구합니다. 거리 비교의 목적으로
 `-distanceTo:(NMGWebMercatorCoord *)`에서 제곱근까지 구할 필요가 없을 때 사용하면 좋습니다.
 
 @param other 다른 좌표.
 @return 거리. 미터 단위.
 */
- (double)squareDistanceTo:(nonnull NMGWebMercatorCoord *)other;

/**
 다른 좌표와의 각도를 구합니다. 다른 좌표가 현재 좌표의 정북 방향에 있을 경우 <code>0</code>도이며, 시계 방향으로
 각도가 증가합니다.
 
 @param other 다른 좌표.
 @return 각도. 도 단위.
 */
- (double)bearingTo:(nonnull NMGWebMercatorCoord *)other;

@end

static inline NMGWebMercatorCoord * _Nonnull NMGWebMercatorCoordMake(double x, double y) NS_SWIFT_UNAVAILABLE("Not use in swift.") {
    return [NMGWebMercatorCoord coordWithX:x y:y];
}
