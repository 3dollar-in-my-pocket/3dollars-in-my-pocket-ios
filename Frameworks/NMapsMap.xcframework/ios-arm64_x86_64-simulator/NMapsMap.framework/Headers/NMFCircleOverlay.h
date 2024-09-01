#import <Foundation/Foundation.h>
#import <NMapsGeometry/NMapsGeometry.h>

#import "NMFOverlay.h"

@class NMGLatLng;

/**
 기본 원 오버레이 전역 Z 인덱스
 */
const static int NMF_CIRCLE_OVERLAY_GLOBAL_Z_INDEX = -200000;

NS_ASSUME_NONNULL_BEGIN

/**
 지도에 원을 나타내는 오버레이.
 */
NMF_EXPORT
@interface NMFCircleOverlay : NMFOverlay

/**
 중심점. 원을 지도에 추가하기 전에 반드시 이 속성에 값을 지정해야 합니다.
 */
@property(nonatomic) NMGLatLng *center;

/**
 반경. 미터 단위. 반경이 `0`일 경우 오버레이가 그려지지 않습니다.
 
 기본값은 `1000`입니다.
 */
@property(nonatomic) double radius;

/**
 오버레이가 차지하는 영역.
 
 기본값은 빈(`isEmpty`가 `YES`인) 영역입니다.
*/
@property(nonatomic, readonly) NMGLatLngBounds *bounds;

/**
 색상.
 
 기본값은 `UIColor.whiteColor`입니다.
 */
@property(nonatomic, copy) UIColor *fillColor;

/**
 테두리의 두께. pt 단위. `0`일 경우 테두리가 그려지지 않습니다.
 
 기본값은 `0`입니다.
 */
@property(nonatomic) double outlineWidth;

/**
 테두리의 색상.
 
 기본값은 `UIColor.blackColor`입니다.
*/
@property(nonatomic, copy) UIColor *outlineColor;

/**
 중심점과 반경을 지정해서 원 오버레이를 생성합니다.

 @param center 중심점.
 @param radius 원의 반경. 미터 단위.
 @return `NMFCircleOverlay` 객체.
 */
+ (instancetype)circleOverlay:(NMGLatLng *)center radius:(double)radius;

/**
 중심점, 반경, 색상을 지정해서 원 오버레이를 생성합니다.

 @param center 중심점.
 @param radius 반경. 미터 단위.
 @param fillColor 색상.
 @return `NMFCircleOverlay` 객체.
 */
+ (instancetype)circleOverlay:(NMGLatLng *)center
                       radius:(double)radius
                    fillColor:(UIColor *)fillColor;
@end

NS_ASSUME_NONNULL_END
