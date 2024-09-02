#import <UIKit/UIKit.h>

/**
 위치 추적 모드를 나타내는 열거형.
 */
typedef NS_ENUM(NSUInteger, NMFMyPositionMode) {
    /**
     위치 추적을 사용하지 않는 모드. `NMFLocationOverlay`는 움직이지 않습니다.
     */
    NMFMyPositionDisabled = 0,
    
    /**
     위치는 추적하지만 지도는 움직이지 않는 모드. `NMFLocationOverlay`가 사용자의 위치를 따라 움직이나 지도는
     움직이지 않습니다.
     */
    NMFMyPositionNormal = 1,
    
    /**
     위치를 추적하면서 카메라도 따라 움직이는 모드. `NMFLocationOverlay`와 카메라의 좌표가 사용자의 위치를 따라
     움직입니다. API나 제스처를 사용해 지도를 임의로 움직일 경우 모드가 `NMFMyPositionNormal`로 바뀝니다.
     */
    NMFMyPositionDirection = 2,

    /**
     위치를 추적하면서 카메라의 좌표와 헤딩도 따라 움직이는 모드. `NMFLocationOverlay`와 카메라의 좌표,
     헤딩이 사용자의 위치, 사용자가 바라보고 있는 방향을 따라 움직입니다. API나 제스처를 사용해 지도를 임의로 움직일
     경우 모드가 `NMFMyPositionNormal`로 바뀝니다.
     */
    NMFMyPositionCompass = 3
};
