#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import "NMFOverlay.h"
#import "NMFMarkerConstants.h"
#import "NMFInfoWindow.h"

@class NMGLatLng;
@class NMFOverlayImage;

NS_ASSUME_NONNULL_BEGIN

/**
 너비 또는 높이가 자동임을 나타내는 상수. 너비 또는 높이가 자동일 경우 아이콘 이미지의 크기에 맞춰집니다.
 */
const static int NMF_MARKER_SIZE_AUTO = 0;

/**
 기본 마커 전역 Z 인덱스
 */
const static int NMF_MARKER_GLOBAL_Z_INDEX = 200000;

/**
 파란색 마커 이미지.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_BLUE;
/**
 회색 마커 이미지.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_GRAY;
/**
 녹색 마커 이미지.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_GREEN;
/**
 하늘색 마커 이미지.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_LIGHTBLUE;
/**
 분홍색 마커 이미지.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_PINK;
/**
 빨간색 마커 이미지.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_RED;
/**
 노란색 마커 이미지.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_YELLOW;
/**
 검은색 마커 이미지. 색상을 덧입히기에 적합합니다.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_BLACK;
/**
 기본 마커 이미지. `NMF_MARKER_IMAGE_GREEN`과 동일합니다.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_DEFAULT;

/**
 저밀도 클러스터 마커 이미지.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_CLUSTER_LOW_DENSITY;
/**
 중밀도 클러스터 마커 이미지.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_CLUSTER_MEDIUM_DENSITY;
/**
 고밀도 클러스터 마커 이미지.
 */
extern NMF_EXPORT NMFOverlayImage *NMF_MARKER_IMAGE_CLUSTER_HIGH_DENSITY;

/**
 기본 앵커. 가운데 아래를 가리킵니다.
 
 @see `NMFMarker.anchor`
 */
extern const NMF_EXPORT CGPoint NMF_MARKER_ANCHOR_DEFAULT;

/**
 아이콘과 캡션을 이용해 지도 위의 한 지점을 표시하는 오버레이.
 */
NMF_EXPORT
@interface NMFMarker : NMFOverlay

/**
 사용자가 임의로 지정할 수 있는 태그. 마커를 그루핑하거나 구분하기 위한 목적으로 사용할 수 있습니다.
 */
@property (nonatomic) NSUInteger tag;

/**
 아이콘.
 */
@property (nonatomic, strong) NMFOverlayImage *iconImage;

/**
 아이콘에 덧입힐 색상. 덧입힐 색상을 지정하면 덧입힐 색상이 아이콘 이미지의 색상과 가산 혼합됩니다. 단, 덧입힐 색상의
 알파는 무시됩니다.
 
 기본값은 `UIColor.clearColor`입니다.
 */
@property (nonatomic, strong) UIColor *iconTintColor;

/**
 아이콘의 너비. pt 단위. `NMF_MARKER_SIZE_AUTO`일 경우 이미지의 너비를 따릅니다.
 
 기본값은 `NMF_MARKER_SIZE_AUTO`입니다.
 */
@property (nonatomic) CGFloat width;

/**
 아이콘의 높이. pt 단위. `NMF_MARKER_SIZE_AUTO`일 경우 이미지의 높이를 따릅니다.
 
 기본값은 `NMF_MARKER_SIZE_AUTO`입니다.
 */
@property (nonatomic) CGFloat height;

/**
 아이콘에 원근 효과를 적용할지 여부. 원근 효과를 적용할 경우 가까운 아이콘은 크게, 먼 아이콘은 작게 표시됩니다.
 
 기본값은 `NO`입니다.
 */
@property (nonatomic) BOOL iconPerspectiveEnabled;

/**
 캡션에 원근 효과를 적용할지 여부. 원근 효과를 적용할 경우 가까운 캡션은 크게, 먼 캡션은 작게 표시됩니다.
 
 기본값은 `NO`입니다.
 */
@property (nonatomic) BOOL captionPerspectiveEnabled;

/**
 마커를 평평하게 설정할지 여부. 마커가 평평할 경우 지도가 회전하거나 기울어지면 마커 이미지도 함께 회전하거나
 기울어집니다. 단, 마커가 평평하더라도 이미지의 크기는 항상 동일하게 유지됩니다.
 
 기본값은 `NO`입니다.
 */
@property (nonatomic, getter=isFlat) BOOL flat;

 /**
 마커와 지도 심벌이 겹칠 경우 지도 심벌을 숨길지 여부.
  
 기본값은 `NO`입니다.
 */
@property (nonatomic) BOOL isHideCollidedSymbols;

/**
 마커와 다른 마커가 겹칠 경우 다른 마커를 숨길지 여부.
 
 기본값은 `NO`입니다.
 */
@property (nonatomic) BOOL isHideCollidedMarkers;

/**
 마커와 다른 마커의 캡션이 겹칠 경우 다른 마커의 캡션을 숨길지 여부.
 
 기본값은 `NO`입니다.
 */
@property (nonatomic) BOOL isHideCollidedCaptions;

/**
 마커가 `isHideCollidedMarkers`이 `YES`인 다른 마커와 겹치더라도 아이콘을 무조건 표시할지 여부.
 
 기본값은 `NO`입니다.
 */
@property (nonatomic) BOOL isForceShowIcon;

/**
 마커가 `isHideCollidedCaptions`이 `YES`인 다른 마커와 겹치더라도 캡션을 무조건 표시할지 여부.
 
 기본값은 `NO`입니다.
 */
@property (nonatomic) BOOL isForceShowCaption;

/**
 좌표. 마커를 지도에 추가하기 전에 반드시 이 속성에 값을 지정해야 합니다.
 */
@property (nonatomic, strong) NMGLatLng *position;

/**
 불투명도. `0`일 경우 완전히 투명, `1`일 경우
 완전히 불투명함을 의미합니다.
 
 기본값은 `1`입니다.
 */
@property (nonatomic) CGFloat alpha;

/**
 앵커. 앵커는 아이콘 이미지에서 기준이 되는 지점을 의미합니다. 앵커로 지정된 지점이 정보 창의 좌표에
 위치합니다. 값의 범위는 `(0, 0)`~`(1, 1)`이며, `(0, 0)`일 경우 이미지의 왼쪽 위,
 `(1, 1)`일 경우 이미지의 오른쪽 아래를 의미합니다.
 
 기본값은 `(0.5, 1)`입니다.
 */
@property (nonatomic) CGPoint anchor;

/**
 아이콘의 각도. 도 단위. 각도를 지정하면 아이콘이 해당 각도만큼 시계 방향으로 회전합니다.
 
 기본값은 `0`입니다.
 */
@property (nonatomic) CGFloat angle;

/**
 캡션 텍스트. 빈 문자열일 경우 캡션이 표시되지 않습니다.
 
 기본값은 빈 문자열입니다.
 */
@property (nonatomic, copy) NSString *captionText;

/**
 캡션의 텍스트 색상.
 
 기본값은 `UIColor.blackColor`입니다.
 */
@property (nonatomic, strong) UIColor *captionColor;

/**
 캡션의 외곽 색상.
 
 기본값은 `UIColor.whiteColor`입니다.
 */
@property (nonatomic, strong) UIColor *captionHaloColor;

/**
 캡션의 텍스트 크기. pt 단위.
 
 기본값은 `12`입니다.
 */
@property(nonatomic) CGFloat captionTextSize;

/**
 캡션의 너비. pt 단위. 지정할 경우 한 줄의 너비가 희망 너비를 초과하는 캡션 텍스트가 자동으로 개행됩니다.
 자동 개행은 어절 단위로 이루어지므로, 하나의 어절이 길 경우 캡션의 너비가 희망 너비를 초과할 수 있습니다.
 `0`일 경우 너비를 제한하지 않습니다.
 
 기본값은 `0`입니다.
 */
@property(nonatomic) CGFloat captionRequestedWidth;

/**
 캡션이 보이는 최소 줌 레벨. 지도의 줌 레벨이 캡션의 최소 줌 레벨보다 작을 경우 아이콘만 나타나고
 주 캡션 및 보조 캡션은 나타나지 않습니다.
 
 기본값은 `NMF_MIN_ZOOM`입니다.
 */
@property(nonatomic) double captionMinZoom;

/**
 캡션이 보이는 최대 줌 레벨. 지도의 줌 레벨이 캡션의 최대 줌 레벨보다 클 경우 아이콘만 나타나고
 주 캡션 및 보조 캡션은 나타나지 않습니다.
 
 기본값은 `NMF_MAX_ZOOM`입니다.
 */
@property(nonatomic) double captionMaxZoom;

/**
 보조 캡션의 텍스트. 보조 캡션은 주 캡션의 아래에 나타납니다. 빈 문자열일 경우 보조 캡션이 표시되지 않습니다.
 
 기본값은 빈 문자열입니다.
 */
@property (nonatomic, copy) NSString *subCaptionText;

/**
 보조 캡션의 텍스트 색상.
 
 기본값은 `UIColor.blackColor`입니다.
 */
@property (nonatomic, strong) UIColor *subCaptionColor;

/**
 보조 캡션의 외곽 색상.
 
 기본값은 `UIColor.whiteColor`입니다.
 */
@property (nonatomic, strong) UIColor *subCaptionHaloColor;

/**
 보조 캡션의 텍스트 크기. pt 단위.
 
 기본값은 `12`입니다.
 */
@property(nonatomic) CGFloat subCaptionTextSize;

/**
 보조 캡션의 너비. pt 단위. 지정할 경우 한 줄의 너비가 희망 너비를 초과하는 캡션 텍스트가 자동으로 개행됩니다.
 자동 개행은 어절 단위로 이루어지므로, 하나의 어절이 길 경우 캡션의 너비가 희망 너비를 초과할 수 있습니다.
 `0`일 경우 너비를 제한하지 않습니다.
 
 기본값은 `0`입니다.
 */
@property(nonatomic) CGFloat subCaptionRequestedWidth;

/**
 보조 캡션이 보이는 최소 줌 레벨. 지도의 줌 레벨이 보조 캡션의 최소 줌 레벨보다 작을 경우 아이콘 및
 주 캡션만 나타나고 보조 캡션은 나타나지 않습니다.
 
 기본값은 `NMF_MIN_ZOOM`입니다.
 */
@property(nonatomic) double subCaptionMinZoom;

/**
 보조 캡션이 보이는 최대 줌 레벨. 지도의 줌 레벨이 보조 캡션의 최대 줌 레벨보다 클 경우 아이콘 및 주
 캡션만 나타나고 보조 캡션은 나타나지 않습니다.
 
 기본값은 `NMF_MAX_ZOOM`입니다.
 */
@property(nonatomic) double subCaptionMaxZoom;

/**
 캡션 아이콘의 정렬 방향.
 
 기본값은 `NMFAlignBottom`입니다.
 
 @warning Deprecated. `captionAligns` 속성을 사용하세요.
 */
@property(nonatomic) NMFAlign captionAlign __deprecated_msg("Use `captionAligns` instead.");

/**
 캡션을 아이콘의 어느 방향에 위치시킬지를 지정합니다. 캡션은 `captionAligns` 배열에 지정된 순서대로 우선적으로
 위치합니다. 만약 캡션이 다른 마커와 겹치지 않거나 겹치더라도 해당 마커의  `isHideCollidedCaptions`가
 `NO`라면 캡션은 반드시 `captionAligns[0]`에 위치합니다. 그렇지 않을 경우 겹치지 않은 다음
 방향에 위치하며, 어느 방향으로 위치시켜도 다른 마커와 겹칠 경우 캡션이 숨겨집니다.
 
 기본값은 `NMFAlignType.bottom`입니다.
 
 @see `NMFAlignType`
 */
@property(nonatomic) NSArray<NMFAlignType *> *captionAligns;

/**
 아이콘과 캡션 간의 여백.
 
 기본값은 `0`입니다.
 */
@property(nonatomic) CGFloat captionOffset;

/**
 마커에 열려 있는 정보 창.
*/
@property (nonatomic, strong, nullable, readonly) NMFInfoWindow *infoWindow;

/**
 위치를 지정하여 마커를 생성합니다.

 @param position 좌표.
 @return `NMFMarker` 객체.
 */
+(instancetype)markerWithPosition:(NMGLatLng *)position;

/**
 위치와 아이콘을 지정하여 마커를 생성합니다.
 
 @param position 좌표.
 @param iconImage 아이콘.
 @return `NMFMarker` 객체.
 */
+(instancetype)markerWithPosition:(NMGLatLng *)position iconImage:(NMFOverlayImage *)iconImage;

@end

NS_ASSUME_NONNULL_END
