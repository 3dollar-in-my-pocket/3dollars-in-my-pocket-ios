#import <UIKit/UIKit.h>

#import "NMFFoundation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 NMFPath, NMFMultipartPath의 색상을 지정하는 클래스.
 */
NMF_EXPORT
@interface NMFPathColor : NSObject

/**
 경로선의 색상. 경로선의 색상은 반투명일 수 없으며, 완전히 투명하거나 완전히 불투명해야 합니다. 색상의
 알파가 `0`이 아닌 경우 완전히 불투명한 것으로 간주됩니다. 색상이 투명할 경우 테두리도 그려지지 않습니다.
 
 기본값은 `UIColor.whiteColor`입니다.
 */
@property (nonatomic, strong) UIColor *color;

/**
 경로선의 테두리 색상. 경로선의 테두리 색상은 반투명일 수 없으며, 완전히 투명하거나 완전히 불투명해야
 합니다. 색상의 알파가 `0`이 아닌 경우 완전히 불투명한 것으로 간주됩니다.
 
 기본값은 `UIColor.blackColor`입니다.
 */
@property (nonatomic, strong) UIColor *outlineColor;

/**
 지나온 경로선의 색상. 지나온 경로선의 색상은 반투명일 수 없으며, 완전히 투명하거나 완전히 불투명해야
 합니다. 색상의 알파가 `0`이 아닌 경우 완전히 불투명한 것으로 간주됩니다. 색상이 투명할 경우 테두리도
 그려지지 않습니다.
 
 기본값은 `UIColor.whiteColor`입니다.
 */
@property (nonatomic, strong) UIColor *passedColor;

/**
 지나온 경로선의 테두리 색상. 지나온 경로선의 테두리 색상은 반투명일 수 없으며, 완전히 투명하거나
 완전히 불투명해야 합니다. 색상의 알파가 `0`이 아닌 경우 완전히 불투명한 것으로 간주됩니다. 색상이 투명할
 경우 테두리도 그려지지 않습니다.
 
 기본값은 `UIColor.blackColor`입니다.
 */
@property (nonatomic, strong) UIColor *passedOutlineColor;

+ (instancetype)pathColorWithColor:(UIColor *)color;

+ (instancetype)pathColorWithColor:(UIColor *)color
                      outlineColor:(UIColor *)outlineColor;

+ (instancetype)pathColorWithColor:(UIColor *)color
                      outlineColor:(UIColor *)outlineColor
                       passedColor:(UIColor *)passedColor
                passedOutlineColor:(UIColor *)passedOutlineColor;
@end

NS_ASSUME_NONNULL_END
