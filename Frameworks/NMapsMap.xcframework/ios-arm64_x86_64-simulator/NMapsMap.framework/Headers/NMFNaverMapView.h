#import <UIKit/UIKit.h>

#import "NMFFoundation.h"
#import "NMFMyPositionMode.h"

@class NMFMapView;

@protocol NMFMapViewDelegate;

/**
 지도의 컨트롤을 내장한 지도 뷰 클래스.
 */
NMF_EXPORT
@interface NMFNaverMapView : UIView

/**
 지도 뷰 객체.
 
 @see `NMFMapView`
 */
@property(nonatomic, readonly, nonnull) NMFMapView *mapView;

/**
 지도 뷰에 관련된 업데이트 및 비동기 작업의 결과를 알려주는 델리게이트. 이 속성은 더이상 사용이 권장되지 않습니다. 대신 `NMFMapView`의 `touchDelegate`, `addCameraDelegate`/`removeCameraDelegate`, `addOptionDelegate`/`removeOptionDelegate`를 사용하세요.
 
 @see `NMFMapViewDelegate`
 */
@property(nonatomic, weak, nullable) IBOutlet id<NMFMapViewDelegate> delegate __attribute__((deprecated("Use delegates of NMFMapView")));

/**
 나침반 활성화 여부.
 
 기본값은 `YES`입니다.
 */
@property(nonatomic, assign) IBInspectable BOOL showCompass;

/**
 축척 바 활성화 여부.
 
 기본값은 `YES`입니다.
 */
@property(nonatomic, assign) IBInspectable BOOL showScaleBar;

/**
 줌 컨트롤 활성화 여부.
 
 기본값은 `YES`입니다.
 */
@property(nonatomic, assign) IBInspectable BOOL showZoomControls;

/**
 실내지도 층 피커 활성화 여부.
 
 기본값은 `NO`입니다.
 */
@property(nonatomic, assign) IBInspectable BOOL showIndoorLevelPicker;

/**
 현 위치 버튼이 활성화되어 있는지 여부.
 
 기본값은 `NO`입니다.
 */
@property(nonatomic, assign) IBInspectable BOOL showLocationButton;

/**
 위치 추적 모드.  이 속성은 더이상 사용이 권장되지 않습니다. 대신 `NMFMapView`의 `positionMode`를 사용하세요.
 
 @see `NMFMyPositionMode`
 */
@property(nonatomic) NMFMyPositionMode positionMode __attribute__((deprecated("Use NMFMapView.positionMode")));

/**
 현재 지도의 스냅숏을 촬영합니다. 스냅숏이 촬영되면 `complete` 가 호출됩니다.
 `takeSnapShot:YES complete:complete` 와 동일합니다.
 
 @param complete 지도 스냅숏이 촬영되면 실행되는 블록 메서드.
 */
- (void)takeSnapShot:(void (^_Nullable)(UIImage * _Nonnull))complete;

/**
 컨트롤을 포함한 현재 지도의 스냅숏을 촬영합니다. 스냅숏이 촬영되면 `complete` 가 호출됩니다.
 
 @param showControls 컨트롤 노출 여부. 노출할 경우 `YES`, 그렇지 않을 경우 `NO`.
 @param complete 지도 스냅숏이 촬영되면 실행되는 블록 메서드.
 */
- (void)takeSnapshotWithShowControls:(BOOL)showControls complete:(void (^_Nullable)(UIImage * _Nonnull))complete;

@end
