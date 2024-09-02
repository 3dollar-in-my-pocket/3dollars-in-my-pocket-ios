#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import "NMFFoundation.h"

@class NMFMapView;
@class NMGLatLng;
@class NMGLatLngBounds;

NS_ASSUME_NONNULL_BEGIN

/**
 지리적 좌표와 화면 좌표 간의 변환을 담당하는 클래스. 이 클래스의 인스턴스는 직접 생성할 수 없고
 `NMFMapView.projection`을 이용해서 가져올 수 있습니다.
 */
NMF_EXPORT
@interface NMFProjection : NSObject

/**
 화면 좌표를 위경도 좌표로 변환합니다.
 
 @param point 화면 좌표.
 @return 위경도 좌표. `point`가 `nil`이거나 화면 좌표의 범위가 위경도 좌표로 표현할 수 있는 범위를 벗어난 경우 유효하지 않은(`NMGLatLng.isValid()`가 `NO`인) 좌표가 반환됩니다.
 */
- (NMGLatLng *)latlngFromPoint:(CGPoint)point;

/**
 화면 좌표를 카메라가 지정된 줌 레벨, 틸트/베어링 각도일 때의 위경도 좌표로 변환합니다. 일반적인 상황에는 `-latlngFromPoint:point:`를 사용하세요.
 
 @param point 화면 좌표.
 @param zoom 줌 레벨.
 @param tilt 틸트 각도.
 @param heading 헤딩 각도.
 @param wrap 좌표를 랩핑할지 여부.
 @return 위경도 좌표. `point`가 `nil`이거나 화면 좌표의 범위가 위경도 좌표로 표현할 수 있는 범위를 벗어난 경우 유효하지 않은(`NMGLatLng.isValid()`가 `NO`인) 좌표가 반환됩니다.
 */
- (NMGLatLng *)latlngFromPoint:(CGPoint)point atZoom:(double)zoom atTilt:(double)tilt atHeading:(double)heading withWrap:(BOOL)wrap;

/**
 위경도 좌표를 화면 좌표로 변환합니다.

 @param coord 위경도 좌표.
 @return 화면 좌표. `coord`가 `nil`이거나, 위경도 좌표의 범위가 화면 좌표로 표현할 수 있는 범위를 벗어난 경우 유효하지 않은(`CGPoint.x` 또는 `CGPoint.y`가 무한대인) 좌표가 반환됩니다.
 */
- (CGPoint)pointFromLatLng:(NMGLatLng *)coord;

/**
 위경도 좌표를 카메라가 지정된 줌 레벨, 틸트/베어링 각도일 때의 화면 좌표로 변환합니다. 일반적인 상황에는 `-pointFromLatLng:coord:`를 사용하세요.

 @param coord 위경도 좌표.
 @param zoom 줌 레벨.
 @param tilt 틸트 각도.
 @param heading 헤딩 각도.
 @param shortestPath 가까운 좌표를 사용할지 여부.
 @return 화면 좌표. `coord`가 `nil`이거나, 위경도 좌표의 범위가 화면 좌표로 표현할 수 있는 범위를 벗어난 경우 유효하지 않은(`CGPoint.x` 또는 `CGPoint.y`가 무한대인) 좌표가 반환됩니다.
 */
- (CGPoint)pointFromLatLng:(NMGLatLng *)coord atZoom:(double)zoom atTilt:(double)tilt atHeading:(double)heading withShortestPath:(BOOL)shortestPath;

/**
 화면의 영역을 위경도 영역으로 변환합니다.

 @param viewBounds 화면 영역.
 @return 위경도 영역.
 */
- (NMGLatLngBounds *)latlngBoundsFromViewBounds:(CGRect)viewBounds;

/**
 위경도 영역을 화면 영역으로 변환합니다.

 @param latlngBounds 위경도 영역.
 @return 화면 영역.
 */
- (CGRect)viewBoundsFromLatLngBounds:(NMGLatLngBounds *)latlngBounds;

/**
 현재 지도의 축척을 반환합니다.

 @return 축척. 미터/픽셀 단위.
 */
- (CLLocationDistance)metersPerPixel;

/**
 카메라의 위도가 `latitude`, 줌 레벨이 `zoom`일 때의 축적을 반환합니다.

 @param latitude 위도.
 @param zoom 줌 레벨.
 @return 축척. 미터/픽셀 단위.
 */
- (CLLocationDistance)metersPerPixelAtLatitude:(double)latitude zoom:(double)zoom;

@end
NS_ASSUME_NONNULL_END


