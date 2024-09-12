//
//  NMGUtils.h
//  NMGeometryFramework
//
//  Created by Won-Young Son on 2017. 1. 10..
//  Copyright © 2017년 NAVER. All rights reserved.
//

#import "NMGGeometry.h"

@class NMGPoint;
@class NMGLatLng;
@class NMGLineString;

/**
 지오메트리와 관련된 유틸리티 기능을 제공하는 클래스.
 */
NMG_EXPORT
@interface NMGUtils : NSObject

/**
 `line`에 `point`가 포함되어 있는지 여부를 반환합니다.
 
 @param point 확인할 점.
 @param line 확인할 라인스트링.
 @return 라인스트링이 점을 포함하고 있는지 여부.
 */
+ (BOOL)isContainPoint:(nonnull NMGPoint *)point inLineString:(nonnull NMGLineString *)line;

/**
 라인스트링 안에 위경도 좌표가 포함되어 있는지 확인합니다.
 
 @param latLng 확인할 위경도 좌표.
 @param line 확인할 라인스트링.
 @return 라인스트링이 위경도 좌표을 포함하고 있는지 여부.
 */
+ (BOOL)isContainLatLng:(nonnull NMGLatLng *)latLng inLineString:(nonnull NMGLineString *)line;

/**
 라인스트링의 길이를 계산합니다.
 
 @param line 라인스트링.
 @return 라인스트링 길이.
 */
+ (double)lengthForLineString:(nonnull NMGLineString *)line;

/**
 `value`를 `[min, max]` 범위로 래핑한다. `value`가 `min`보다 작거나
 `max`보다 클 경우 값이 순환된다.
 
 @param value 래핑할 값.
 @param min 최솟값.
 @param max 최댓값.
 @return 래핑된 값.
 */
+ (double)wrap:(double)value min:(double)min max:(double)max;

/**
 `value`를 `[min, max]` 범위로 래핑한다. `value`가 `min`보다 작거나
 `max`보다 클 경우 값이 순환된다.
 
 @param value 래핑할 값.
 @param min 최솟값.
 @param max 최댓값.
 @return 래핑된 값.
 */
+ (int)wrapi:(int)value min:(int)min max:(int)max;

@end
