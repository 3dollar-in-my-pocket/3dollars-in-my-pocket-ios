NS_ASSUME_NONNULL_BEGIN

/**
 지도 최초 로딩에 대한 콜백 프로토콜. 지도의 데이터가 모두 로딩되어 최초로 화면에 나타나면
 이벤트가 발생합니다. 이벤트는 한 번만 발생하며, 이후에는 카메라가 움직이거나
 지도의 옵션이 변경되어 데이터가 새로 로딩되더라도 발생하지 않습니다.
 */
@protocol NMFMapViewLoadDelegate <NSObject>

@optional

/**
 지도가 처음 로딩되면 호출되는 콜백 메서드.

 @param mapView 로딩된 지도.
 */
- (void)mapViewDidFinishLoadingMap:(NMFMapView *)mapView;

@end

NS_ASSUME_NONNULL_END
