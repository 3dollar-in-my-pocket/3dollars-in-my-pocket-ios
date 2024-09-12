#import "NMFFoundation.h"

NS_ASSUME_NONNULL_BEGIN

@class NMGLatLng;

/**
 지도에 노출되어야 하는 마커의 속성을 나타내는 클래스.
 이 클래스의 인스턴스는 불변이며 모든 스레드에서 안전하게 접근할 수 있습니다.
 */
NMF_EXPORT
@interface NMCMarkerInfo : NSObject

/**
 태그.
 */
@property (nonatomic, nullable, readonly) NSObject *tag;

/**
 좌표.
 */
@property (nonatomic, nonnull, readonly) NMGLatLng *position;

/**
 마커가 노출되는 최소 줌 레벨.
 */
@property (nonatomic, assign, readonly) NSInteger minZoom;

/**
 마커가 노출되는 최대 줌 레벨.
 */
@property (nonatomic, assign, readonly) NSInteger maxZoom;

@end

NS_ASSUME_NONNULL_END
