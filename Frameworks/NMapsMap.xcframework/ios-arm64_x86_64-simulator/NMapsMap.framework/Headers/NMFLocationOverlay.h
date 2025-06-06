#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import "NMFOverlay.h"

NS_ASSUME_NONNULL_BEGIN


/**
 너비 또는 높이가 자동임을 나타내는 상수. 너비 또는 높이가 자동일 경우 아이콘 이미지의 크기에 맞춰집니다.
 */
const static int NMF_LOCATION_OVERLAY_SIZE_AUTO = 0;

/**
 위치 오버레이 기본 색상.
 */
extern UIColor *const NMF_LOCATION_OVERLAY_DEFAULT_COLOR;

/**
 기본 위치 오버레이 Z 인덱스
 */
const static int NMF_LOCATION_OVERLAY_GLOBAL_Z_INDEX = 300000;

@class NMGLatLng;
@class NMFOverlayImage;

/**
 사용자의 현재 위치를 나타내는 오버레이. 이 오버레이는 지도에 단 하나만 존재하며, 인스턴스를 직접 생성할 수 없고
 `NMFMapView.locationOverlay`를 이용해서 가져올 수 있습니다.
 위치 오버레이는 주 아이콘과 보조 아이콘, 원으로 구성됩니다.
 - 주 아이콘: 반드시 필요합니다. 이벤트를 받을 수 있습니다.
 - 보조 아이콘: 생략할 수 있습니다. 주 아이콘보다 약간 아래에 그려집니다. 이벤트를 받을 수 없습니다.
 - 원: 생략할 수 있습니다. 강조 효과를 위해 사용되며, 보조 아이콘 아래에 그려집니다. 이벤트를 받을 수 없습니다.
 */
NMF_EXPORT
@interface NMFLocationOverlay : NMFOverlay

/**
 아이콘의 너비. pt 단위. `NMF_LOCATION_OVERLAY_SIZE_AUTO`일 경우 이미지의 너비를 따릅니다.
 
 기본값은 `NMF_LOCATION_OVERLAY_SIZE_AUTO`입니다.
 */
@property(nonatomic) CGFloat iconWidth;

/**
 이미지의 높이. pt 단위. `NMF_LOCATION_OVERLAY_SIZE_AUTO`일 경우 이미지의 눂이를 따릅니다.
 
 기본값은 `NMF_LOCATION_OVERLAY_SIZE_AUTO`입니다.
 */
@property(nonatomic) CGFloat iconHeight;

/**
 보조 아이콘의 너비. pt 단위. `NMF_LOCATION_OVERLAY_SIZE_AUTO`일 경우 이미지의 너비를 따릅니다.
 
 기본값은 `NMF_LOCATION_OVERLAY_SIZE_AUTO`입니다.
 */
@property(nonatomic) CGFloat subIconWidth;

/**
 보조 이미지의 높이. pt 단위. `NMF_LOCATION_OVERLAY_SIZE_AUTO`일 경우 이미지의 눂이를 따릅니다.
 
 기본값은 `NMF_LOCATION_OVERLAY_SIZE_AUTO`입니다.
 */
@property(nonatomic) CGFloat subIconHeight;

/**
 오버레이의 좌표.
 */
@property(nonatomic, copy) NMGLatLng *location;

/**
 방위. 도 단위. 방위가 북쪽일 경우 `0`도이며, 시계 방향으로 값이 증가합니다.
 
 기본값은 `0`입니다.
 */
@property(nonatomic) CGFloat heading;
/**
 아이콘.
 */
@property(nonatomic, strong) NMFOverlayImage *icon;
/**
 보조 아이콘.
 */
@property(nonatomic, strong, nullable) NMFOverlayImage *subIcon;

/**
 아이콘의 앵커. 앵커는 아이콘 이미지에서 기준이 되는 지점을 의미합니다. 앵커로 지정된 지점이
 오버레이의 좌표에 위치합니다. 값의 범위는 `(0, 0)`~`(1, 1)`이며, `(0, 0)`일 경우
 이미지의 왼쪽 위, `(1, 1)`일 경우 이미지의 오른쪽 아래를 의미합니다.
 
 기본값은 `(0.5, 0.5)`입니다.
 */
@property(nonatomic) CGPoint anchor;

/**
 보조 아이콘의 앵커. 앵커는 보조 아이콘 이미지에서 기준이 되는 지점을 의미합니다. 앵커로 지정된 지점이
 오버레이의 좌표에 위치합니다. 값의 범위는 `(0, 0)`~`(1, 1)`이며, `(0, 0)`일 경우
 이미지의 왼쪽 위, `(1, 1)`일 경우 이미지의 오른쪽 아래를 의미합니다.
 
 기본값은 `(0.5, 1)`입니다.
 */
@property(nonatomic) CGPoint subAnchor;

/**
 원의 색상.
 
 기본값은 `NMF_LOCATION_OVERLAY_DEFAULT_COLOR`입니다.
 */
@property(nonatomic, strong) UIColor *circleColor;

/**
 원의 테두리 색상.
 
 기본값은 `UIColor.clearColor`입니다.
 */
@property(nonatomic, strong) UIColor *circleOutlineColor;

/**
 원의 외곽선 두께. pt 단위. `0`일 경우 테두리가 그려지지 않습니다.
 
 기본값은 `0`입니다.
 */
@property(nonatomic) CGFloat circleOutlineWidth;

/**
 원의 반경. pt 단위. `0`일 경우 원이 그려지지 않습니다.
 
 기본값은 `18`입니다.
 */
@property(nonatomic) CGFloat circleRadius;

/**
 유효한 현 위치의 기본 아이콘 이미지를 반환합니다.

 @return `NMFOverlayImage` 객체.
 */
+ (NMFOverlayImage *)defaultIconImage;
@end

NS_ASSUME_NONNULL_END

