#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMFMapView;
@class NMFSymbol;

/**
 카메라의 움직임에 대한 콜백 프로토콜.
*/
@protocol NMFMapViewCameraDelegate <NSObject>

@optional
/**
 카메라의 움직임이 시작될 때 호출되는 콜백 메서드. 해당 시점의 카메라 위치는 콜백 내에서 `NMFMapView.cameraPosition`으로 얻을 수 있습니다.
 
 @param mapView `NMFMapView` 객체.
 @param reason 움직임의 원인.
 @param animated 애니메이션 효과가 적용돼 움직일 경우 `YES`, 그렇지 않을 경우 `NO`.
 */
- (void)mapView:(NMFMapView *)mapView cameraWillChangeByReason:(NSInteger)reason animated:(BOOL)animated;

/**
 카메라가 움직이고 있을 때 호출되는 콜백 메서드. 해당 시점의 카메라 위치는 콜백 내에서 `NMFMapView.cameraPosition`으로 얻을 수 있습니다.
 
 @param mapView `NMFMapView` 객체.
 @param reason 움직임의 원인.
 */
- (void)mapView:(NMFMapView *)mapView cameraIsChangingByReason:(NSInteger)reason;

/**
 카메라의 움직임이 끝났을 때 호출되는 콜백 메서드. 해당 시점의 카메라 위치는 콜백 내에서 `NMFMapView.cameraPosition`으로 얻을 수 있습니다.
 
 @param mapView `NMFMapView` 객체.
 @param reason 움직임의 원인.
 @param animated 애니메이션 효과가 적용돼 움직인 경우 `YES`, 그렇지 않은 경우 `NO`.
 */
- (void)mapView:(NMFMapView *)mapView cameraDidChangeByReason:(NSInteger)reason  animated:(BOOL)animated;

/**
 카메라의 움직임이 끝나면 호출되는 콜백 메서드. 이 메서드는 다음과 같은 경우에 호출됩니다.
 카메라가 애니메이션 없이 움직일 때. 단, 사용자가 제스처로 지도를 움직이는 경우 제스처가 완전히 끝날 때까지(터치가 끝날 때까지) 연속적인 이동으로 간주되어 이벤트가 발생하지 않습니다.
 카메라 애니메이션이 완료될 때. 단, 카메라 애니메이션이 진행 중일 때 새로운 애니메이션이 발생하거나, 기존 `NMFMapView.moveCamera:completion:`의 콜백 내에서 카메라 이동이 일어날 경우 연속적인 이동으로 간주되어 이벤트가 발생하지 않습니다.
 `NMFMapView.cancelTransitions()`가 호출되어 카메라 애니메이션이 명시적으로 취소될 때.
 해당 시점의 카메라 위치는 콜백 내에서 `mapView.cameraPosition`으로 얻을 수 있습니다.
 
 @param mapView `NMFMapView` 객체.
 */
- (void)mapViewCameraIdle:(NMFMapView *)mapView;

@end

NS_ASSUME_NONNULL_END
