#import <UIKit/UIKit.h>
#import "NMFFoundation.h"

@class NMFOverlay;

NS_ASSUME_NONNULL_BEGIN

/**
 오버레이에서 사용하는 비트맵 이미지를 나타내는 불변 클래스. 팩토리 메서드를 이용해
 asset, `UIImage`, `NSBundle` 등으로부터 인스턴스를 생성할 수 있습니다.
 */
NMF_EXPORT
@interface NMFOverlayImage : NSObject

/**
 재사용 식별자.
 */
@property(nonatomic, readonly, copy) NSString *reuseIdentifier;
/**
 이미지의 너비.
 */
@property(nonatomic, readonly) CGFloat imageWidth;
/**
 이미지의 높이.
 */
@property(nonatomic, readonly) CGFloat imageHeight;
/**
 이미지의 스케일.
 */
@property(nonatomic, readonly) CGFloat imageScale;
/**
 이미지.
 */
@property(nonatomic, readonly) UIImage *image;

/**
 `UIImage`로부터 `NMFOverlayImage` 객체를 생성합니다.
 `reuseIdentifier`는 이미지 객체의 `description`으로 자동 지정됩니다.
 
 @param image 비트맵을 생성할 이미지 객체.
 @return `NMFOverlayImage` 객체.
 */
+ (instancetype)overlayImageWithImage:(UIImage *)image;

/**
 `UIImage`로부터 `NMFOverlayImage` 객체를 생성합니다.
 `reuseIdentifier`는 `identifier`로 지정됩니다.
 
 @param image 비트맵을 생성할 이미지 객체.
 @param identifier 재사용 식별자.
 @return `NMFOverlayImage` 객체.
 */
+ (instancetype)overlayImageWithImage:(UIImage *)image reuseIdentifier:(nullable NSString *)identifier;

/**
 앱의 asset에 존재하는 이미지로부터 `NMFOverlayImage` 객체를 생성합니다.
 `reuseIdentifier`는 이미지 객체의 `description`으로 자동 지정됩니다.
 
 @param imageName 비트맵을 생성할 이미지 asset 이름.
 @return `NMFOverlayImage` 객체.
 */
+ (instancetype)overlayImageWithName:(NSString *)imageName;

/**
 앱의 asset에 존재하는 이미지로부터 `NMFOverlayImage` 객체를 생성합니다.
 `reuseIdentifier`는 `identifier`로 지정됩니다.
 
 @param imageName 비트맵을 생성할 이미지 asset 이름.
 @param identifier 재사용 식별자.
 @return `NMFOverlayImage` 객체.
 */
+ (instancetype)overlayImageWithName:(NSString *)imageName reuseIdentifier:(nullable NSString *)identifier;

/**
 지정한 bundle의 asset에 존재하는 이미지로부터 `NMFOverlayImage` 객체를 생성합니다.
 `reuseIdentifier`는 이미지 객체의 `description`으로 자동 지정됩니다.
 
 @param imageName 비트맵을 생성할 이미지 asset 이름.
 @param bundle 이미지를 찾을 번들.
 @return `NMFOverlayImage` 객체.
 */
+ (instancetype)overlayImageWithName:(NSString *)imageName inBundle:(nullable NSBundle *)bundle;

/**
 지정한 bundle의 asset에 존재하는 이미지로부터 `NMFOverlayImage` 객체를 생성합니다.
 `reuseIdentifier`는 `identifier`로 지정됩니다.
 
 @param imageName 비트맵을 생성할 이미지 asset 이름.
 @param bundle 이미지를 찾을 번들.
 @param identifier 재사용 식별자.
 @return `NMFOverlayImage` 객체.
 */
+ (instancetype)overlayImageWithName:(NSString *)imageName inBundle:(nullable NSBundle *)bundle reuseIdentifier:(nullable NSString *)identifier;

- (void)invalidate;

@end


/**
 지도에서 사용할 수 있는 이미지 리소스를 만들기 위한 `UIView`를 반환할 수 있는 프로토콜.
 이 프로토콜을 구현할 경우, 오버레이의 상태에 따라서 `UIView`를 반환하게 하여 그 스냅숏을
 `NMFOverlay` 클래스에서 이미지 형태로 사용할 수 있습니다.
 */
@protocol NMFOverlayImageDataSource <NSObject>
@required

/**
 스냅숏을 생성하게 될 `UIView`를 반환할 수 있도록 구현해야 합니다. `nil`을 반환하면 이미지를 그리지 않습니다.
 
 @param overlay 이미지를 사용하게 될 `NMFOverlay` 객체.
 @return 스냅숏을 생성할 `UIView` 객체.
 */
- (UIView *)viewWithOverlay:(NMFOverlay *)overlay;

@end


NS_ASSUME_NONNULL_END
