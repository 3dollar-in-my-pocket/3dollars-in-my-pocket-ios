#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMFMapView;

/**
 지도 옵션 변경에 대한 콜백 프로토콜.
 */
@protocol NMFMapViewOptionDelegate <NSObject>

@optional
/**
 지도의 옵션이 변경되면 호출되는 콜백 메서드.
 
 @param mapView `NMFMapView` 객체.
 */
- (void)mapViewOptionChanged:(NMFMapView *)mapView;

@end

NS_ASSUME_NONNULL_END
