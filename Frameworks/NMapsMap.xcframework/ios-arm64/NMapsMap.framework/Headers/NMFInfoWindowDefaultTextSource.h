#import "NMFOverlayImage.h"

#import <UIKit/UIKit.h>

#import "NMFFoundation.h"

@protocol NMFOverlayImageDataSource;

NS_ASSUME_NONNULL_BEGIN

NMF_EXPORT
@interface NMFInfoWindowDefaultTextSource : NSObject <NMFOverlayImageDataSource>

+ (instancetype)dataSource;

@property(nonatomic, readwrite) NSString *title;

@end

NS_ASSUME_NONNULL_END
