#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMFMapView;
@class NMFSymbol;

/**
 지도 터치에 대한 콜백 프로토콜.
*/
@protocol NMFMapViewTouchDelegate <NSObject>

@optional

/**
 지도 심벌이 탭되면 호출되는 콜백 메서드.
 
 @param mapView 지도 객체.
 @param symbol 탭된 심벌.
 @return `YES`일 경우 이벤트를 소비합니다. 그렇지 않을 경우 이벤트가 지도로 전달되어 `mapView:didTapMap:point:`가 호출됩니다.
 */
- (BOOL)mapView:(NMFMapView *)mapView didTapSymbol:(NMFSymbol *)symbol;

/**
 지도가 탭되면 호출되는 콜백 메서드.
 
 @param latlng 탭된 지점의 지도 좌표.
 @param point 탭된 지점의 화면 좌표.
 */
- (void)mapView:(NMFMapView *)mapView didTapMap:(NMGLatLng*)latlng point: (CGPoint)point;

@end

NS_ASSUME_NONNULL_END
