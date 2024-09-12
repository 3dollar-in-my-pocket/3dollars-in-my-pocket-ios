#import <Foundation/Foundation.h>

#import "NMFPickable.h"

@class NMGLatLng;

/**
 지도 위의 아이콘, 텍스트 등 피킹 가능한 심벌을 나타내는 클래스. 이 클래스의 인스턴스는 직접 생성할 수 없으며, 두 가지
 방법으로 얻을 수 있습니다.
  - `NMFMapViewTouchDelegate`의 `-mapView:didTapSymbol:`을 이용해 사용자가 클릭한 심벌 수신
  - `NMFMapView`의 `-pickAll:withTolerance:`를 이용해 특정 화면 좌표 주변의 심벌을 쿼리
 
 - SeeAlso: `NMFPickable`
 */
NMF_EXPORT
@interface NMFSymbol : NSObject <NMFPickable>

/**
 심벌의 좌표.
 */
@property(nonatomic, readonly) NMGLatLng *position;

/**
 캡션 문자열. 캡션이 없는 심벌일 경우 빈 문자열을 반환합니다.
 */
@property(nonatomic, readonly) NSString *caption;

@end
