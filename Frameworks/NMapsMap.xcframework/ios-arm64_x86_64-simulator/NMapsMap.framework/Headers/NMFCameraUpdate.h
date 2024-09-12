#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <NMapsGeometry/NMapsGeometry.h>

#import "NMFFoundation.h"

@class NMFCameraUpdateParams;
@class NMFCameraPosition;
@class NMFMapView;


NS_ASSUME_NONNULL_BEGIN

/**
 개발자가 API를 호출해 카메라가 움직였음을 나타내는 값.
 @see `NMFCameraUpdate.reason`
 */
const static NSInteger NMFMapChangedByDeveloper = 0;

/**
 사용자의 제스처로 인해 카메라가 움직였음을 나타내는 값.
 @see `NMFCameraUpdate.reason`
 */
const static NSInteger NMFMapChangedByGesture = -1;

/**
 사용자의 버튼 선택으로 인해 카메라가 움직였음을 나타내는 값.
 @see `NMFCameraUpdate.reason`
 */
const static NSInteger NMFMapChangedByControl = -2;

/**
 위치 정보 갱신으로 카메라가 움직였음을 나타내는 값.
 @see `NMFCameraUpdate.reason`
 */
const static NSInteger NMFMapChangedByLocation = -3;

/**
 * 카메라 이동 애니메이션 유형을 정의하는 열거형. `NMFCameraUpdate`에서 사용합니다.
 */
typedef NS_ENUM(NSUInteger, NMFCameraUpdateAnimation) {
    /**
     애니메이션 없음.
     */
    NMFCameraUpdateAnimationNone,

    /**
     선형 애니메이션.
     */
    NMFCameraUpdateAnimationLinear,
    
    /**
     부드럽게 가속되는 애니메이션.
     */
    NMFCameraUpdateAnimationEaseIn,
    
    /**
     부드럽게 감속되는 애니메이션.
     */
    NMFCameraUpdateAnimationEaseOut,
    
    /**
     플라잉 애니메이션. 가속과 함께 축소됐다가 감속과 함께 확대됩니다.
     */
    NMFCameraUpdateAnimationFly,
};

/**
 지도를 바라보는 카메라의 이동을 정의하는 클래스. 이 클래스의 인스턴스는 직접 생성할 수 없고, 팩토리 메서드를 이용해서
 생성할 수 있습니다. 생성한 인스턴스를 파라미터로 삼아 `NMFMapView`의 `-moveCamera:`를 호출하면 지도를
 이동할 수 있습니다.
 
 카메라의 이동은 다음과 같은 네 가지 요소로 구성됩니다.
 - 카메라의 위치: 카메라를 이동할 위치. `CameraUpdate`를 생성하는 팩토리 메서드의 파라미터로 지정합니다.
 - 피봇 지점: 카메라 이동의 기준점이 되는 지점. 피봇 지점을 지정하면 이동, 줌 레벨 변경, 회전의 기준점이 해당 지점이 됩니다. `pivot`으로 지정합니다.
 - 애니메이션: 카메라 이동 시 적용될 애니메이션. 애니메이션의 유형과 시간을 지정할 수 있습니다. `animation`과 `animationDuration`으로 지정합니다.
 - 이동 원인: 카메라 이동의 원인. 이 값을 지정하면 `NMFMapViewCameraDelegate`의 메서드에 `reason` 파라미터로 전달됩니다. `reason`으로 지정합니다.
 @see `NMFMapView` `-moveCamera:`
 */
NMF_EXPORT
@interface NMFCameraUpdate : NSObject

/**
 피봇 지점. `0, 0`일 경우 왼쪽 위, `1, 1`일 경우 오른쪽 아래 지점을 의미합니다.
 `-cameraUpdateWithFitBounds:`를 이용해 객체를 생성한 경우에는 무시됩니다.
 */
@property (nonatomic) CGPoint pivot;

/**
 카메라 이동 시 적용할 애니메이션. 애니메이션의 시간은 `DEFAULT_ANIMATION_DURATION`으로 지정됩니다.
 `animation`이 `NMFCameraUpdateAnimationNone`일 경우 지도가 애니메이션 없이 즉시 이동됩니다.
 @see `NMFCameraUpdateAnimation`
 */
@property (nonatomic) NMFCameraUpdateAnimation animation;

/**
 카메라 이동 시 적용할 애니메이션의 시간.
 
 기본값은 `NMFMapView.animationDuration`입니다.
 */
@property (nonatomic) NSTimeInterval animationDuration;

/**
 카메라 이동의 원인.
 
 기본값은 `NMFMapChangedByDeveloper`입니다.
 @see `NMFMapChangedByControl` `NMFMapChangedByGesture` `NMFMapChangedByDeveloper`
 */
@property (nonatomic) int reason;

/**
 `params`를 이용해 카메라를 이동하는 `NMFCameraUpdate` 객체를 생성합니다.
 
 @param params 카메라 이동에 사용할 파라미터.
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithParams:(NMFCameraUpdateParams *)params;

/**
 카메라를 `position` 위치로 이동하는 `NMFCameraUpdate` 객체를 생성합니다.
 
 @param position 새로운 카메라 위치.
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithPosition:(NMFCameraPosition *)position;

/**
 카메라의 좌표를 `target`으로 변경하는 `NMFCameraUpdate` 객체를 생성합니다.
 줌 레벨, 기울기 각도, 헤딩 각도 등 좌표 외의 다른 속성은 변하지 않습니다.
 
 @param target 새로운 카메라 좌표.
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithScrollTo:(NMGLatLng *)target;

/**
 카메라의 좌표를 `target`으로, 줌 레벨을 `zoom`으로 변경하는 `NMFCameraUpdate` 객체를 생성합니다.
 기울기 각도, 헤딩 각도 등 좌표와 줌 레벨 외의 다른 속성은 변하지 않습니다.
 
 @param target 새로운 카메라 좌표.
 @param zoom 새로운 카메라 줌 레벨.
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithScrollTo:(NMGLatLng *)target zoomTo:(double)zoom;

/**
 카메라를 현재 위치에서 `delta` 포인트만큼 이동하도록 지정하는 `NMFCameraUpdate` 객체를 생성합니다.
 줌 레벨, 기울기 각도, 헤딩 각도 등 좌표 외의 다른 속성은 변하지 않습니다.
 
 @param delta 이동할 거리. pt 단위.
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithScrollBy:(CGPoint)delta;

/**
 카메라의 줌 레벨을 `1`만큼 증가하는 `NMFCameraUpdate` 객체를 생성합니다.
 좌표, 기울기 각도, 헤딩 각도 등 줌 레벨 외의 다른 속성은 변하지 않습니다.
 
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithZoomIn;

/**
 카메라의 줌 레벨을 `1`만큼 감소하는 `NMFCameraUpdate` 객체를 생성합니다.
 좌표, 기울기 각도, 헤딩 각도 등 줌 레벨 외의 다른 속성은 변하지 않습니다.
 
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithZoomOut;

/**
 카메라의 줌 레벨을 `zoom`으로 변경하는 `NMFCameraUpdate` 객체를 생성합니다.
 좌표, 기울기 각도, 헤딩 각도 등 줌 레벨 외의 다른 속성은 변하지 않습니다.
 
 @param zoom 새로운 카메라 줌 레벨.
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithZoomTo:(double)zoom;

/**
 카메라의 헤딩 각도를 `heading`로 변경하는 `NMFCameraUpdate` 객체를 생성합니다.
 좌표, 기울기 각도, 줌 레벨 등 헤딩 각도 외의 다른 속성은 변하지 않습니다.
 
 @param heading 새로운 카메라 헤딩 각도.
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithHeading:(double)heading;

/**
 `bounds`가 화면에 온전히 보이는 좌표와 최대 줌 레벨로 카메라의 위치를 변경하는 `NMFCameraUpdate` 객체를 생성합니다.
 기울기 각도와 베어링 각도는 `0`으로 변경되며, 피봇 지점은 무시됩니다.
 
 @param bounds 카메라로 볼 영역.
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithFitBounds:(NMGLatLngBounds *)bounds;

/**
 `bounds`가 화면에 온전히 보이는 좌표와 최대 줌 레벨로 카메라의 위치를 변경하는 `NMFCameraUpdate` 객체를 생성합니다.
 기울기 각도와 베어링 각도는 `0`으로 변경되며, 피봇 지점은 무시됩니다.
 
 @param bounds 카메라로 볼 영역.
 @param padding 카메라가 변경된 후 영역과 지도 화면 간 확보할 최소 여백. pt 단위.
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithFitBounds:(NMGLatLngBounds *)bounds padding:(CGFloat)padding;

/**
 `bounds`가 화면에 온전히 보이는 좌표와 최대 줌 레벨로 카메라의 위치를 변경하는 `NMFCameraUpdate` 객체를 생성합니다.
 기울기 각도와 베어링 각도는 `0`으로 변경되며, 피봇 지점은 무시됩니다.
 
 @param bounds 카메라로 볼 영역.
 @param paddingInsets 카메라가 변경된 후 영역과 지도 화면 간 확보할 인셋 여백. pt 단위.
 @return `NMFCameraUpdate` 객체.
 */
+ (instancetype)cameraUpdateWithFitBounds:(NMGLatLngBounds *)bounds paddingInsets:(UIEdgeInsets)paddingInsets;

@end


NS_ASSUME_NONNULL_END

