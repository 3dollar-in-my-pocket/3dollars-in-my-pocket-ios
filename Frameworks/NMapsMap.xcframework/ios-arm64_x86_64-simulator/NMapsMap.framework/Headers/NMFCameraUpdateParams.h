
#import <Foundation/Foundation.h>

@class NMFCameraPosition;
@class NMFMapView;
@class NMGLatLng;

NS_ASSUME_NONNULL_BEGIN

/**
 카메라를 이동할 지점에 관한 다양한 정보를 나타내는 클래스. 주로 `NMFCameraUpdate`를 만들기 위한 파라미터로 사용됩니다.
 `target`, `zoom`, `tilt`, `heading` 등 카메라 위치에 대한 네 가지 속성을 나타내는 것은 `NMFCameraPosition`과 유사하지만,
 `NMFCameraPosition`은 하나의 절대적인 카메라 위치를 나타내는 데 반해 `NMFCameraUpdateParams`는 상대적인 변화를 줄 수 있습니다.
 이를 위해서 하나의 속성에 각각 두 종류의 메서드를 제공합니다.
 
 - `xxxTo:`: 속성을 절대적인 값으로 지정합니다.
 - `xxxBy:`: 속성을 현재 지도의 `cameraPosition`의 상대적인 값으로 지정합니다.
 
 동일한 속성에 대해 `xxxTo:` 계열의 메서드와 `xxxBy:` 계열의 메서드를 모두 호출하면 앞선 호출은 무시됩니다.
 
 @see `NMFCameraUpdate.cameraUpdateWithParams:`
 */
NMF_EXPORT
@interface NMFCameraUpdateParams : NSObject

@property(nonatomic, readonly) bool isScrolled;

/**
 기본 생성자.
 */
+ (instancetype)cameraUpdateParams;

- (NMFCameraPosition *)cameraPositionWithMap:(NMFMapView *)mapView pivot:(CGPoint)pivot;


/**
 카메라의 좌표를 `target`으로 변경하도록 지정합니다.
 
 @param target 지정할 좌표.
 */
- (void)scrollTo:(NMGLatLng *)target;

/**
 카메라를 현재 위치에서 `delta` pt만큼 이동하도록 지정합니다.
 
 @param delta 이동할 거리. pt 단위.
 */
- (void)scrollBy:(CGPoint)delta;

/**
 카메라의 줌 레벨을 `zoom`으로 변경하도록 지정합니다.
 
 @param zoom 지정할 줌 레벨.
 */
- (void)zoomTo:(double)zoom;

/**
 카메라의 즘 레벨을 `delta`만큼 변경하도록 지정합니다. 양수로 지정할 경우 확대, 음수로 지정할 경우 축소됩니다.
 
 @param delta 줌 레벨의 변화량.
 */
- (void)zoomBy:(double)delta;

/**
 카메라의 줌 레벨을 `1`만큼 증가하도록 지정합니다.
 */
- (void)zoomIn;

/**
 카메라의 줌 레벨을 `1`만큼 감소하도록 지정합니다.
 */
- (void)zoomOut;

/**
 카메라의 기울기 각도를 `tilt`로 변경하도록 지정합니다.
 
 @param tilt 기울기 각도. 도 단위.
 */
- (void)tiltTo:(double)tilt;

/**
 카메라의 기울기 각도를 `delta`만큼 변경하도록 지정합니다. 양수로 지정하면 지도가 기울어지고 음수로 지정하면 수직에 가까워집니다.
 
 @param delta 기울기 각도의 변화량. 도 단위.
 */
- (void)tiltBy:(double)delta;

/**
 카메라의 헤딩 각도를 `heading`으로 변경하도록 지정합니다.
 
 @param heading 헤딩 각도. 도 단위.
 */
- (void)rotateTo:(double)heading;

/**
 카메라의 헤딩 각도를 `delta`만큼 변경하도록 지정합니다.
 
 @param delta 헤딩 각도의 변화량. 도 단위.
 */
- (void)rotateBy:(double)delta;

@end


NS_ASSUME_NONNULL_END

