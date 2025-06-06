#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "NMFGeometry.h"
#import "NMFPickable.h"

@class NMFMapView;
@class NMFOverlay;

NS_ASSUME_NONNULL_BEGIN

/**
 오버레이를 어느 방향으로 정렬할지 나타내는 열거형.
 
 @warning Deprecated. `NMFAlignType`을 사용하세요.
 */
typedef NS_ENUM(NSInteger, NMFAlign) {
    /**
     가운데.
     */
    NMFAlignCenter,
    
    /**
     왼쪽.
     */
    NMFAlignLeft,
    
    /**
     오른쪽.
     */
    NMFAlignRight,
    
    /**
     위.
     */
    NMFAlignTop,
    
    /**
     아래.
     */
    NMFAlignBottom,
    
    /**
     왼쪽 위.
     */
    NMFAlignTopLeft,
    
    /**
     오른쪽 위.
     */
    NMFAlignTopRight,
    
    /**
     오른쪽 아래.
     */
    NMFAlignBottomRight,
    
    /**
     왼쪽 아래.
     */
    NMFAlignBottomLeft
} __deprecated_msg("Use `NMFAlignType` instead.");

/**
 오버레이를 어느 방향으로 정렬할지 나타내는 객체.
 속성 객체로만 사용해야 합니다.
 */
NMF_EXPORT
@interface NMFAlignType : NSObject <NSSecureCoding, NSCopying>

/**
 가운데.
 */
@property(class, nonatomic, readonly) NMFAlignType *center;

/**
 왼쪽.
 */
@property(class, nonatomic, readonly) NMFAlignType *left;

/**
 오른쪽.
 */
@property(class, nonatomic, readonly) NMFAlignType *right;

/**
 위.
 */
@property(class, nonatomic, readonly) NMFAlignType *top;

/**
 아래.
 */
@property(class, nonatomic, readonly) NMFAlignType *bottom;

/**
 왼쪽 위.
 */
@property(class, nonatomic, readonly) NMFAlignType *topLeft;

/**
 오른쪽 위.
 */
@property(class, nonatomic, readonly) NMFAlignType *topRight;

/**
 오른쪽 아래.
 */
@property(class, nonatomic, readonly) NMFAlignType *bottomRight;

/**
 왼쪽 아래.
 */
@property(class, nonatomic, readonly) NMFAlignType *bottomLeft;

+ (NMFAlignType *)center;
+ (NMFAlignType *)left;
+ (NMFAlignType *)right;
+ (NMFAlignType *)top;
+ (NMFAlignType *)bottom;
+ (NMFAlignType *)topLeft;
+ (NMFAlignType *)topRight;
+ (NMFAlignType *)bottomRight;
+ (NMFAlignType *)bottomLeft;

@end

/**
 끝 지점의 모양
 */
typedef NS_ENUM(NSUInteger, NMFOverlayLineCap) {
    /**
     평면. 끝 지점이 좌표에 딱 맞게 잘립니다.
     */
    NMFOverlayLineCapButt,
    /**
     원형. 끝 지점에 지름이 두께만 한 원이 그려집니다.
     */
    NMFOverlayLineCapRound,
    /**
     사각형. 끝 지점에 두께의 반만큼의 직사각형이 추가됩니다.
     */
    NMFOverlayLineCapSquare,
};

/**
 연결점의 모양.
 */
typedef NS_ENUM(NSUInteger, NMFOverlayLineJoin) {
    /**
     사면. 연결점에서 뾰족하게 튀어나온 부분이 잘려 나갑니다.
     */
    NMFOverlayLineJoinBevel,
    /**
     원형. 연결점이 둥글게 그려집니다.
     */
    NMFOverlayLineJoinRound,
    /**
     미터. 연결점이 뾰족하게 그려집니다.
     */
    NMFOverlayLineJoinMiter,
};

/**
 오버레이 터치에 대한 이벤트 핸들러 블록 타입 선언.
 
 @return `YES`일 경우 이벤트를 소비합니다. 그렇지 않을 경우 `NMFMapView`까지 이벤트가 전달되어 `NMFMapViewTouchDelegate`의 `mapView:didTapMap:point:`가 호출됩니다.
 */
typedef BOOL (^NMFOverlayTouchHandler)(NMFOverlay * __weak);


/**
 지도에 오버레이되는 요소를 나타내는 최상위 클래스. 대부분의 오버레이는 `mapView`를 사용해 동적으로 지도에 추가하거나 지도로부터 제거할 수 있습니다.
 */
NMF_EXPORT
@interface NMFOverlay : NSObject <NMFPickable>

/**
 오버레이의 고유 ID.
 */
@property(nonatomic, copy, readonly) NSString *overlayID;

/**
 사용자 임의 속성. 필요에 따라서 부가적인 정보를 저장할 수 있습니다.
 */
@property(nonatomic, strong) NSDictionary *userInfo;

/**
 오버레이를 추가할 지도 객체. `nil`을 지정하면 지도에서 제거됩니다.
 */
@property(nonatomic, weak, nullable) NMFMapView *mapView;

/**
 숨김 속성. `YES`일 경우 오버레이는 화면에 나타나지 않으며 이벤트도 받지 못합니다.
 숨김 속성은 명시적으로 지정하지 않는 한 변하지 않습니다. 즉, 오버레이가 현재 보이는 지도 영역의 바깥쪽으로
 나가더라도 숨김 속성이 `YES`로 변하지는 않습니다.
 
 기본값은 `NO`입니다.
 */
@property(nonatomic) BOOL hidden;

/**
 보조 Z 인덱스. 전역 Z 인덱스가 동일한 여러 오버레이가 화면에서 겹쳐지면 보조 Z 인덱스가 큰
 오버레이가 작은 오버레이를 덮습니다.
 
 기본값은 `0`입니다.
 */
@property(nonatomic) NSInteger zIndex;

/**
 전역 Z 인덱스. 여러 오버레이가 화면에서 겹쳐지면 전역 Z 인덱스가 큰 오버레이가 작은 오버레이를
 덮습니다. 또한 값이 `0` 이상이면 오버레이가 심벌 위에, `0` 미만이면 심벌 아래에 그려집니다.
 */
@property(nonatomic) NSInteger globalZIndex;

/**
 오버레이가 보이는 최소 줌 레벨.
 
 기본값은 `NMF_MIN_ZOOM`입니다.
 */
@property(nonatomic) double minZoom;

/**
 오버레이가 보이는 최대 줌 레벨.
 
 기본값은 `NMF_MAX_ZOOM`입니다.
 */
@property(nonatomic) double maxZoom;

/**
 지도의 줌 레벨과 오버레이의 최소 줌 레벨이 동일할 때 오버레이를 보일지 여부를 반환합니다.
 만약 `YES`이면 오버레이가 나타나고 `NO`이면 나타나지 않습니다.
 
 기본값은 `YES`입니다.
 */
@property(nonatomic, setter=setMinZoomInclusive:) BOOL isMinZoomInclusive;

/**
 지도의 줌 레벨과 오버레이의 최대 줌 레벨이 동일할 때 오버레이를 보일지 여부를 반환합니다.
 만약 `YES`이면 오버레이가 나타나고 `NO`이면 나타나지 않습니다.
 
 기본값은 `YES`입니다.
 */
@property(nonatomic, setter=setMaxZoomInclusive:) BOOL isMaxZoomInclusive;

/**
 오버레이가 터치될 경우 호출되는 콜백 블록.
 */
@property(nonatomic, nullable) NMFOverlayTouchHandler touchHandler;

/**
 오버레이가 유효하여 지도에 추가될 수 있는지 여부를 반환합니다. `NMFOverlay`를 상속받는 오버레이들은 이 메서드를 재정의할 수 있습니다.
 
 기본값은 `NO`입니다.
 
 @return 지도에 추가될 수 있다면 `YES`, 아니면 `NO`.
 */
- (BOOL)shouldAddOverlayToMap;

@end

NS_ASSUME_NONNULL_END
