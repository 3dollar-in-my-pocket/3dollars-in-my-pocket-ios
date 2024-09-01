#import <UIKit/UIKit.h>

#import "NMFFoundation.h"

NS_ASSUME_NONNULL_BEGIN

@class NMFIndoorSelection;
@class NMFMapView;

/**
 실내지도 층 피커 컨트롤.
 */
NMF_EXPORT
@interface NMFIndoorLevelPickerView : UIView <UITableViewDelegate, UITableViewDataSource>
/**
 이 컨트롤과 연결할 지도 객체. `nil`일 경우 컨트롤이 동작하지 않습니다.
 
 기본값은 `nil`입니다.
 */
@property (nonatomic, weak, nullable) NMFMapView *mapView;

/**
 실내지도 층 피커의 높이에 대한 NSLayoutConstraint 객체.
*/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *viewHeightConstraint;

@end

NS_ASSUME_NONNULL_END
