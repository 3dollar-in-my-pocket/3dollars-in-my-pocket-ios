#import <CoreLocation/CoreLocation.h>

#import "NMFFoundation.h"

@class NMGLatLng;

NS_ASSUME_NONNULL_BEGIN

/**
 카메라의 위치 관련 정보를 나타내는 불변 클래스. 카메라의 위치는 좌표, 줌 레벨, 기울기 각도, 헤딩 각도로 구성됩니다.
 */
NMF_EXPORT
@interface NMFCameraPosition : NSObject <NSSecureCoding, NSCopying>

/**
 카메라의 좌표.
 */
@property (nonatomic, strong, readonly) NMGLatLng *target;

/**
 줌 레벨. 이 값이 증가할수록 축척이 증가합니다.
 */
@property (nonatomic, readonly) double zoom;

/**
 기울기 각도. 도 단위. 카메라가 지면을 내려다보는 각도를 나타냅니다. 천정에서 지면을 수직으로 내려다보는 경우 `0`도이며, 비스듬해질수록 값이 증가합니다.
 */
@property (nonatomic, readonly) double tilt;

/**
 헤딩 각도. 도 단위. 카메라가 바라보는 방위를 나타냅니다. 방위가 북쪽일 경우 `0`도이며, 시계 방향으로 값이 증가합니다.
 */
@property (nonatomic, readonly) double heading;

/**
 카메라 위치에 관한 모든 요소를 지정해 객체를 생성합니다.
 
 @param target 카메라의 좌표.
 @param zoom 카메라의 줌 레벨.
 @param tilt 카메라의 기울기 각도.
 @param heading 카메라의 베어링 각도.
 
 @return `NMFCameraPosition` 객체.
 */
+ (instancetype)cameraPosition:(NMGLatLng *)target zoom:(double)zoom tilt:(double)tilt heading:(double)heading;

/**
 좌표와 줌 레벨로부터 객체를 생성합니다. `tilt`와 `heading`은 `0`으로 지정됩니다.
 
 @param target 카메라의 좌표.
 @param zoom 카메라의 줌 레벨.
 
 @return `NMFCameraPosition` 객체.
 */
+ (instancetype)cameraPosition:(NMGLatLng *)target zoom:(double)zoom;

/**
 카메라의 위치가 유효한지 여부를 반환합니다.
 
 @return 카메라의 위치가 유효한지 여부.
 */
- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
