#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NMFGeometry.h"
#import "NMFOverlay.h"

NS_ASSUME_NONNULL_BEGIN

/**
 기본 지상 오버레이 전역 Z 인덱스
 */
const static int NMF_GROUND_OVERLAY_GLOBAL_Z_INDEX = -300000;

@class NMFOverlayImage;
@class NMGLatLngBounds;

/**
 지도에서 특정 영역을 나타내는 오버레이. 지도에 추가하기 전에 반드시 `bounds` 및
 `overlayImage`를 지정해야 합니다.
 */
NMF_EXPORT
@interface NMFGroundOverlay : NMFOverlay

/**
 영역. 지상 오버레이가 지도에 추가되기 전에 반드시 이 속성을 지정해야 합니다.
 
 기본값은 빈(`isEmpty`가 `YES`인) 영역입니다.
 */
@property(nonatomic, strong) NMGLatLngBounds *bounds;

/**
 이미지.
 */
@property(nonatomic, strong) NMFOverlayImage *overlayImage;

/**
 불투명도. `0`일 경우 완전히 투명, `1`일 경우 완전히 불투명함을 의미합니다.
 
 기본값은 `1`입니다.
 */
@property(nonatomic) CGFloat alpha;

/**
 영역과 이미지를 지정하여 지상 오버레이를 생성합니다.

 @param bounds 영역.
 @param overlayImage 이미지.
 @return `NMFGroundOverlay` 객체.
 */
+ (instancetype)groundOverlayWithBounds:(NMGLatLngBounds *)bounds image:(NMFOverlayImage *)overlayImage;

@end

NS_ASSUME_NONNULL_END
