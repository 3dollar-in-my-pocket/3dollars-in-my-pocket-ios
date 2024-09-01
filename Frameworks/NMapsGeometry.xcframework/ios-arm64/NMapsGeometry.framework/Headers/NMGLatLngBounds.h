//
//  NMGLatLngBounds.h
//  NMGeometryFramework
//
//  Created by mrtajo on 2017. 2. 6..
//  Copyright © 2017년 NAVER. All rights reserved.
//

#import "NMGGeometry.h"

@class NMGLatLng;

/**
 남서쪽과 북동쪽 두 위경도 좌표로 이루어진
 <a href="https://terms.naver.com/entry.nhn?docId=3479529&amp;cid=58439&amp;categoryId=58439">최소 경계 사각형</a>
 영역을 나타내는 클래스.
 */
NMG_EXPORT
@interface NMGLatLngBounds : NSObject <NMGBoundable>

/**
 남서쪽 좌표.
 */
@property (nonatomic, nonnull) NMGLatLng *southWest;

/**
 북동쪽 좌표.
 */
@property (nonatomic, nonnull) NMGLatLng *northEast;

/**
 영역의 중심점 좌표.
 */
@property (nonatomic, readonly, nonnull) NMGLatLng *center;

/**
 영역의 위도(세로) 폭. 도 단위.
 */
@property (nonatomic, readonly) double latSpan;

/**
 영역의 경도(가로) 폭. 도 단위.
 */
@property (nonatomic, readonly) double lngSpan;

/**
 최남단의 위도.
 */
@property (nonatomic, readonly) double southWestLat;

/**
 최서단의 경도.
 */
@property (nonatomic, readonly) double southWestLng;

/**
 최북단의 위도.
 */
@property (nonatomic, readonly) double northEastLat;

/**
 최동단의 위도.
 */
@property (nonatomic, readonly) double northEastLng;

/**
 영역을 배열로 변환합니다. 배열의 크기는 `2`이며, 각 원소는 순서대로 영역의 남서쪽, 북동쪽 좌표를
 나타냅니다.
 */
@property (nonatomic, readonly, nonnull) NSArray<NMGLatLng *> *boundsLatLngs;

+ (nonnull instancetype)bounds;

/**
 `latLngs`의 좌표를 모두 포함하는 최소한의 `NMGLatLngBounds` 객체를 생성합니다.

 @param latLngs 포함할 좌표들
 @return `NMGLatLngBounds` 객체
*/
+ (nonnull instancetype)latLngBoundsWithLatLngs:(nonnull NSArray<NMGLatLng *> *)latLngs;

/**
* 남서쪽과 북동쪽 좌표로부터 객체를 생성합니다.
 
 @param southWest 남서쪽 좌표.
 @param northEast 북동쪽 좌표.
 @return `NMGLatLngBounds` 객체
*/
+ (nonnull instancetype)latLngBoundsSouthWest:(nonnull NMGLatLng *)southWest northEast:(nonnull NMGLatLng *)northEast;

/**
* 남서쪽과 북동쪽 좌표로부터 객체를 생성합니다.
 
 @param southWestLat 남서쪽 좌표의 위도
 @param southWestLng 남서쪽 좌표의 경도
 @param northEastLat 북동쪽 좌표의 위도
 @param northEastLng 북동쪽 좌표의 경도
 @return `NMGLatLngBounds` 객체
*/
+ (nonnull instancetype)latLngBoundsWithSouthWestLat:(double)southWestLat southWestLng:(double)southWestLng northEastLat:(double)northEastLat northEastLng:(double)northEastLng;

/**
 영역이 좌표를 포함하는지 여부를 반환합니다.
 
 @param point 포함되는지 확인할 좌표.
 @return 포함할 경우 `YES`, 그렇지 않을 경우 `NO`.
 */
- (BOOL)hasPoint:(nonnull NMGLatLng *)point;

/**
 영역이 다른 영역을 포함하는지 여부를 반환합니다.
 
 @param bounds 포함되는지 확인할 영역.
 @return 포함할 경우 `YES`, 그렇지 않을 경우 `NO`.
 */
- (BOOL)hasBounds:(nonnull NMGLatLngBounds *)bounds;

/**
 영역이 다른 영역과 교차하는지 여부를 반환합니다.
 
 @param bounds 교차하는지 확인할 영역.
 @return 교차할 경우 `YES`, 그렇지 않을 경우 `NO`.
 */
- (BOOL)isIntersect:(nonnull NMGLatLngBounds *)bounds;

/**
 영역과 다른 영역 간의 교차 영역을 반환합니다.
 
 @param bounds 다른 영역.
 @return 교차 영역. 두 영역이 교차하지 않을 경우 `nil`.
 */
- (nullable NMGLatLngBounds *)intersectionWithBounds:(nonnull NMGLatLngBounds *)bounds __attribute__((warn_unused_result));

/**
 `point`를 포함하도록 확장한 영역을 반환합니다. 영역이 이미 `point`를 포함하고 있을 경우
 새로운 객체가 만들어지지 않고 이 객체가 반환됩니다.
 
 @param point 포함할 좌표.
 @return 좌표가 포함된 영역.
 */
- (nonnull NMGLatLngBounds *)expandToPoint:(nonnull NMGLatLng *)point __attribute__((warn_unused_result));

/**
 현재 영역과 다른 영역을 모두 포함하는 최소한의 영역을 구합니다.
 
 @param bounds 다른 영역.
 @return 두 영역을 모두 포함하는 영역.
 */
- (nonnull NMGLatLngBounds *)unionBounds:(nonnull NMGLatLngBounds *)bounds __attribute__((warn_unused_result));

@end

static inline NMGLatLngBounds * _Nonnull NMGLatLngBoundsMake(double southWestLat, double southWestLng, double northEastLat, double northEastLng) NS_SWIFT_UNAVAILABLE("Not use in swift.") {
    return [NMGLatLngBounds latLngBoundsWithSouthWestLat:southWestLat southWestLng:southWestLng northEastLat:northEastLat northEastLng:northEastLng];
}


