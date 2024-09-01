#import "NMFFoundation.h"

NS_ASSUME_NONNULL_BEGIN

@class NMFIndoorSelection;

/**
 실내 지도 구역 및 층 선택에 대한 콜백 프로토콜.
 */
@protocol NMFIndoorSelectionDelegate <NSObject>

/**
 선택된 실내지도 구역 및 층이 변경될 경우 호출됩니다.

 @param indoorSelection 선택된 실내지도에 대한 `NMFIndoorSelection` 객체. 실내지도가 보이지 않을 경우 `nil`.
 */
- (void)indoorSelectionDidChanged:(NMFIndoorSelection * _Nullable)indoorSelection;

@end

NS_ASSUME_NONNULL_END
