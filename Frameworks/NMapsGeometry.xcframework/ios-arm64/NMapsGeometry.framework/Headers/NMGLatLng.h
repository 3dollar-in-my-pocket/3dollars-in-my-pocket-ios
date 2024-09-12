//
//  NMGLatLng.h
//  NMGeometryFramework
//
//  Created by Won-Young Son on 2017. 1. 10..
//  Copyright © 2017년 NAVER. All rights reserved.
//

#import "NMGGeometry.h"

@class NMGLatLngBounds;
@class NMGXyz;

/**
 최소 위도. 도 단위.
 */
const static double NMG_LAT_LNG_MINIMUM_LATITUDE    = -90;

/**
 최대 위도. 도 단위.
 */
const static double NMG_LAT_LNG_MAXIMUM_LATITUDE    = 90;

/**
 최소 경도. 도 단위.
 */
const static double NMG_LAT_LNG_MINIMUM_LONGITUDE   = -180;

/**
 최대 경도. 도 단위.
 */
const static double NMG_LAT_LNG_MAXIMUM_LONGITUDE   = 180;

/**
 위경도 좌표를 나타내는 클래스.
 
 `CLLocationCoordinate2D`과 달리 위도와 경도를 `double`형으로 표현합니다.
 */
NMG_EXPORT
@interface NMGLatLng : NSObject <NMGPointable>

/**
 위도. 도 단위.
 */
@property (nonatomic) double lat;

/**
 경도. 도 단위.
 */
@property (nonatomic) double lng;

/**
 위경도 좌표로 나타낼 수 있는 커버리지 영역. 전 세계
 
 @return `NMGLatLngBounds` 객체.
 */
+ (nonnull NMGLatLngBounds *)coverage;

/**
 * 유효하지 않은(`isValid`가 `NO`인) 좌표를 나타내는 상수.
 */
+ (nonnull NMGLatLng *)invalid;

/**
 위도와 경도가 `DBL_MAX`인 객체를 생성합니다.
 
 @return NMGLatLng 객체.
 */
+ (nonnull instancetype)latLng;

/**
 위도와 경도로 객체를 생성합니다.
 
 @param lat 위도.
 @param lng 경도.
 @return NMGLatLng 객체.
 */
+ (nonnull instancetype)latLngWithLat:(double)lat lng:(double)lng;

/**
 `CLLocationCoordinate2D`로부터 객체를 생성합니다.
 
 @param coordinate CLLocationCoordinate2D 객체.
 @return NMGLatLng 객체.
 */
+ (nonnull instancetype)latLngFromCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 @return self.
 */
- (nonnull NMGLatLng *)toLatLng;

/**
 좌표가 좌표계의 커버리지 내에 포함되는지 여부를 반환합니다. 커버리지를 벗어날 경우 좌표 연산의 정확도가 보장되지
 않습니다.
 
 @return 커버리지 내일 경우 `YES`, 그렇지 않을 경우 `NO`.
 */
- (BOOL)isWithinCoverage;

/**
 이 좌표의 `lng`를 [`NMG_LAT_LNG_MINIMUM_LONGITUDE`, `NMG_LAT_LNG_MAXIMUM_LONGITUDE`] 범위로 래핑한 좌표를
 반환합니다. `lng` 이미 해당 범위에 속해 있을 경우 새로운 객체가 만들어지지 않고 이 객체가
 반환됩니다.
 
 @return 경도가 래핑된 좌표 객체.
 */
- (nonnull NMGLatLng *)wrap;

/**
 다른 좌표와의 거리를 반환합니다.
 
 @param other 거리를 잴 다른 좌표.
 @return 좌표 간의 거리. 미터 단위.
 */
- (double)distanceTo:(nonnull NMGLatLng *)other __attribute__((warn_unused_result));

/**
 이 좌표로부터 북쪽으로 `northMeter`미터, 동쪽으로 `eastMeter`미터만큼 떨어진 좌표를
 반환합니다.
 
 @param northMeter 북쪽 방향 거리. 미터 단위.
 @param eastMeter 동쪽 방향 거리. 미터 단위.
 @return 좌표.
 */
- (nonnull NMGLatLng *)offset:(double)northMeter withEastMeter:(double)eastMeter __attribute__((warn_unused_result));

@end

static inline NMGLatLng * _Nonnull NMGLatLngMake(double lat, double lng) NS_SWIFT_UNAVAILABLE("Not use in swift.") {
    return [NMGLatLng latLngWithLat:lat lng:lng];
}
