#import <UIKit/UIKit.h>

#import "NMFTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class NMFMapView;
@class NMFSymbol;
@class NMFIndoorRegion;

/**
 `NMFMapView`에 관련된 업데이트 및 비동기 작업의 결과를 알려주는 콜백 메서드가 정의된 프로토콜. 이 프로토콜은 더이상 사용이 권장되지 않습니다. `NMFMapViewTouchDelegate`, `NMFMapViewCameraDelegate`, `NMFMapViewOptionDelegate`를 사용하세요.
 */
__attribute__((deprecated("Use NMFMapViewTouchDelegate, NMFMapViewCameraDelegate or NMFMapViewOptionDelegate")))
@protocol NMFMapViewDelegate <NSObject>

@optional

#pragma mark Responding to Map Position Changes

/**
 지도가 표시하는 영역이 변경될 때 호출되는 콜백 메서드.
 
 @param mapView 영역이 변경될 `NMFMapView` 객체.
 @param animated 애니메이션 효과가 적용돼 움직일 경우 `YES`, 그렇지 않을 경우 `NO`.
 @param reason 움직임의 원인.
 */
- (void)mapView:(NMFMapView *)mapView regionWillChangeAnimated:(BOOL)animated byReason:(NSInteger)reason;

/**
 지도가 표시하고 있는 영역이 변경되고 있을 때 호출되는 콜백 메서드.
 
 @param mapView 영역이 변경되고 있는 `NMFMapView` 객체.
 @param reason 움직임의 원인.
 */
- (void)mapViewRegionIsChanging:(NMFMapView *)mapView byReason:(NSInteger)reason;

/**
 지도가 표시하고 있는 영역이 변경되었을 때 호출되는 콜백 메서드.
 
 @param mapView 영역이 변경된 `NMFMapView` 객체.
 @param animated 애니메이션 효과가 적용돼 움직인 경우 `YES`, 그렇지 않은 경우 `NO`.
 @param reason 움직임의 원인.
 */
- (void)mapView:(NMFMapView *)mapView regionDidChangeAnimated:(BOOL)animated byReason:(NSInteger)reason;

/**
 현재 진행 중인 지도 이동 애니메이션이 취소되었을때 호출되는 콜백 메서드.
 
 @param mapView 영역이 변경되고 있었던 `NMFMapView` 객체.
 @param reason 취소된 원인.
 */
- (void)mapViewCameraUpdateCancel:(NMFMapView *)mapView byReason:(NSInteger)reason;

/**
 지도가 표시하고 있는 영역이 변경된 후 진행 중인 터치 이벤트가 없을 때 호출되는 콜백 메서드.
 
 @param mapView 영역이 변경된 `NMFMapView` 객체.
 */
- (void)mapViewIdle:(NMFMapView *)mapView;

#pragma mark Responding to Map TouchEvent

/**
 사용자가 지도의 심벌을 탭하면 호출됩니다.
 
 @param mapView `NMFMapView` 객체.
 @param symbol 탭한 지도 심벌 객체.
 @return `YES`일 경우 이벤트를 소비합니다. 그렇지 않을 경우 `NMFMapView`까지 이벤트가 전달되어 `NMFMapViewDelegate`의 `didTapMapView`가 호출됩니다.
 */
- (BOOL)mapView:(NMFMapView *)mapView didTapSymbol:(NMFSymbol *)symbol;

/**
 사용자가 지도를 탭하면 호출됩니다.
 
 @param point 탭한 화면 좌표.
 @param latlng 탭한 위경도 좌표.
 */
- (void)didTapMapView:(CGPoint)point LatLng:(NMGLatLng*)latlng;

@end

NS_ASSUME_NONNULL_END
