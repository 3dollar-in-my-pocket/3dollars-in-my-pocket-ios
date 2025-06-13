#import "NMFMapViewCameraDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 지도 렌더링에 대한 콜백 프로토콜.
 */
@protocol NMFMapViewRenderDelegate <NSObject>

@optional

/**
 지도가 렌더링되면 호출되는 콜백 메서드.
 `-mapView:CameraIsChangingByReason:` 보다도 빈번하게 호출되기 때문에 성능에 영향을 줄 여지가 있습니다.

 @param mapView 렌더링된 지도.
 @param fully 모든 데이터가 렌더링되었으면 `YES`, 그렇지 않을 경우 `NO`.
 @param stable 추가 렌더링이 필요하지 않다면 `YES`, 그렇지 않을 경우 `NO`.
 */
- (void)mapViewDidFinishRenderingFrame:(NMFMapView *)mapView
                                 fully:(BOOL)fully
                                stable:(BOOL)stable;

@end

NS_ASSUME_NONNULL_END
