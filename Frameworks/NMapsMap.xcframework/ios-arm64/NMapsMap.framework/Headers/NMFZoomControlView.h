#import <UIKit/UIKit.h>

#import "NMFFoundation.h"

NS_ASSUME_NONNULL_BEGIN

@class NMFMapView;

/**
 줌 버튼 컨트롤.
 */
NMF_EXPORT
@interface NMFZoomControlView : UIView

/**
 이 컨트롤과 연결할 지도 객체. `nil`일 경우 컨트롤이 동작하지 않습니다.
 
 기본값은 `nil`입니다.
 */
@property (nonatomic, weak, nullable) NMFMapView *mapView;

@end

NS_ASSUME_NONNULL_END
