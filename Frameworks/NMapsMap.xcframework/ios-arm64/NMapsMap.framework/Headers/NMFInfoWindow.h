#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NMFOverlay.h"

NS_ASSUME_NONNULL_BEGIN

/**
 기본 정보창 전역 Z 인덱스
 */
const static int NMF_INFO_WINDOW_GLOBAL_Z_INDEX = 400000;

@class NMGLatLng;
@class NMFMarker;
@protocol NMFOverlayImageDataSource;

/**
 지도의 특정 지점 또는 마커 위에 열 수 있는 정보 창. 정보 창은 이미지로 특정 지점을 표시한다는 점에서 마커와 유사하나,
 다음과 같은 차이가 있습니다.
 - 마커처럼 특정 좌표에 열 수 있을 뿐만 아니라 다른 마커 위에도 열 수 있습니다.
 - 고정된 이미지를 지정하는 마커와 달리 이미지를 반환하는 어댑터를 지정할 수 있으므로, 객체/상황별로 다른 이미지를
 노출할 수 있습니다.
 */
NMF_EXPORT
@interface NMFInfoWindow : NMFOverlay

/**
 불투명도. `0`일 경우 완전히 투명, `1`일 경우
 완전히 불투명함을 의미합니다.
 
 기본값은 `1`입니다.
 */
@property(nonatomic) CGFloat alpha;

/**
 정보 창에서 사용할 이미지를 제공해 줄 수 있는 이미지 데이터 소스.
 */
@property(nonatomic) id<NMFOverlayImageDataSource> dataSource;

/**
 정보 창이 열려 있는 마커.
 */
@property(nonatomic, nullable, readonly) NMFMarker *marker;

/**
 좌표. 좌표는 `-openWithMapView:`를 이용해 정보 창을 여는 경우 사용되며, `-openWithMarker:`를
 이용해 여는 경우에는 마커의 위치에 정보 창이 열리므로 무시됩니다.
 
 기본값은 유효하지 않은(`isValid`가 `NO`인) 좌표입니다.
 */
@property(nonatomic) NMGLatLng *position;

/**
 앵커. 앵커는 아이콘 이미지에서 기준이 되는 지점을 의미합니다. 앵커로 지정된 지점이 정보 창의 좌표에
 위치합니다. 값의 범위는 `(0, 0)`~`(1, 1)`이며, `(0, 0)`일 경우 이미지의 왼쪽 위,
 `(1, 1)`일 경우 이미지의 오른쪽 아래를 의미합니다.
 
 기본값은 `(0.5, 1)`입니다.
 */
@property(nonatomic) CGPoint anchor;

/**
 정보 창과 좌표 또는 마커 간의 X축 방향 여백. pt 단위.
 
 기본값은 `0`입니다.
 */
@property(nonatomic) NSInteger offsetX;

/**
 정보 창과 좌표 또는 마커 간의 Y축 방향 여백. pt 단위.
 
 기본값은 `0`입니다.
 */
@property(nonatomic) NSInteger offsetY;

/**
 정보 창을 생성합니다.
 
 @return `NMFInfoWindow` 객체.
 */
+ (instancetype)infoWindow;

/**
 정보 창을 `marker`의 위에 엽니다. `-openWithMarker:marker alignType:NMFAlignType.top`과 동일합니다.
 
 정보 창을 마커 위에 열기 전에는 반드시 `dataSource`를 지정해야 합니다.
 
 @param marker 정보 창을 열 마커.
 */
- (void)openWithMarker:(NMFMarker *)marker;

/**
 정보 창을 `marker`에 엽니다. 정보 창을 열 마커는 반드시 지도에 추가된 상태여야 하며, 그렇지 않을 경우
 무시됩니다. `align`을 이용하면 마커의 어느 방향에 정보 창의 앵커를 위치시킬지 지정할 수 있습니다.
 
 정보 창을 마커 위에 열기 전에는 반드시 `dataSource`를 지정해야 합니다.
 
 @param marker 정보 창을 열 마커.
 @param align 정보 창을 열 방향.
 
 @warning Deprecated. `openWithMarker:alignType:`을 사용하세요.
 */
- (void)openWithMarker:(NMFMarker *)marker align:(NMFAlign)align __deprecated_msg("Use `openWithMarker:alignType:` instead.");

/**
 정보 창을 `marker`에 엽니다. 정보 창을 열 마커는 반드시 지도에 추가된 상태여야 하며, 그렇지 않을 경우
 무시됩니다. `alignType`을 이용하면 마커의 어느 방향에 정보 창의 앵커를 위치시킬지 지정할 수 있습니다.
 
 정보 창을 마커 위에 열기 전에는 반드시 `dataSource`를 지정해야 합니다.
 
 @param marker 정보 창을 열 마커.
 @param alignType 정보 창을 열 방향.
 
 @see `NMFAlignType`
 */
- (void)openWithMarker:(NMFMarker *)marker alignType:(NMFAlignType *)alignType;

/**
 정보 창을 `position` 지점에 엽니다.
 
 정보 창을 특정 지점에 열기 전에는 반드시 `position`과 `dataSource`를 지정해야 합니다.
 
 @param mapView 정보 창을 열 지도 객체.
 */
- (void)openWithMapView:(NMFMapView *)mapView;

/**
 정보 창을 닫습니다. 정보 창이 열려 있지 않은 경우 무시됩니다.
 */
- (void)close;

/**
 이미지를 다시 그립니다.
 */
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
