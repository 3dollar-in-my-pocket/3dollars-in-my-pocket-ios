#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NMFGeometry.h"
#import "NMFOverlay.h"

NS_ASSUME_NONNULL_BEGIN

/**
 기본 폴리곤 오버레이 전역 Z 인덱스
 */
const static int NMF_POLYGON_OVERLAY_GLOBAL_Z_INDEX = -200000;

@class NMGPolygon;

/**
 지도에 도형을 나타내는 오버레이.
 */
NMF_EXPORT
@interface NMFPolygonOverlay : NMFOverlay

/**
 폴리곤 오버레이의 모양을 결정하는 폴리곤 객체.
 폴리곤 오버레이를 생성한 이후 폴리곤을 갱신하기 위한 목적으로 사용할 수 있습니다.
 */
@property (nonatomic) NMGPolygon *polygon;

/**
 면의 색상.
 
 기본값은 `UIColor.whiteColor`입니다.
 */
@property (nonatomic, copy) UIColor *fillColor;

/**
 테두리의 두께. pt 단위. `0`일 경우 테두리가 그려지지 않습니다.
 
 기본값은 `0`입니다.
 */
@property (nonatomic) NSUInteger outlineWidth;

/**
 테두리의 색상.
 
 기본값은 `UIColor.blackColor`입니다.
 */
@property (nonatomic, copy) UIColor *outlineColor;

/**
 폴리곤 객체와 색상을 지정하여 폴리곤 오버레이를 생성합니다.
 폴리곤 객체의 `isValid`속성이 `NO`일 경우 `nil`을 리턴합니다.

 @param polygon 폴리곤 객체.
 @param fillColor 폴리곤을 채울 색상.
 @return `NMFPolygonOverlay` 객체.
 */
+ (nullable instancetype)polygonOverlay:(NMGPolygon *)polygon fillColor:(UIColor *)fillColor;

/**
 폴리곤 객체를 지정하여 폴리곤 오버레이를 생성합니다.
 폴리곤 객체의 `isValid`속성이 `NO`일 경우 `nil`을 리턴합니다.

 @param polygon 폴리곤 객체.
 @return `NMFPolygonOverlay` 객체.
 */
+ (nullable instancetype)polygonOverlay:(NMGPolygon *)polygon;

/**
 외곽선 정점 배열을 지정하여 폴리곤 오버레이를 생성합니다.
 `coords`의 크기는 `2` 이상이어야 합니다.
 
 @param coords `NMGLatLng` 배열.
 @return `NMFPolygonOverlay` 객체.
 */
+ (nullable instancetype)polygonOverlayWith:(NSArray<NMGLatLng *> *)coords;

@end

NS_ASSUME_NONNULL_END
