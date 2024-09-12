#import "NMFFoundation.h"

@class NMGLatLng;
@class NMGWebMercatorCoord;

NS_ASSUME_NONNULL_BEGIN

/**
 `NMCClusterer`가 관리하는 트리 구조의 노드를 의미하는 클래스.
 
 이 클래스의 인스턴스는 모든 스레드에서 접근 가능하고 불변인 `NMCMarkerInfo`와 달리 백그라운드 스레드에서만 접근
 가능하며 데이터가 변경되면 객체의 속성도 변경되므로 사용에 주의해야 합니다.
 */
NMF_EXPORT
@interface NMCNode : NSObject

/**
 태그.
 */
@property (nonatomic, nullable, readonly) NSObject *tag;

/**
 노드가 노출되어야 하는 최소 줌 레벨.
 */
@property (nonatomic, assign, readonly) NSInteger minZoom;

/**
 노드가 노출되어야 하는 최대 줌 레벨.
 */
@property (nonatomic, assign, readonly) NSInteger maxZoom;

/**
 자식 `NMCNode`의 개수.
 */
@property (nonatomic, assign, readonly) NSInteger size;

/**
 웹 메르카토르 좌표.
 */
@property (nonatomic, nonnull, readonly) NMGWebMercatorCoord *coord;

/**
 좌표.
 */
@property (nonatomic, nonnull, readonly) NMGLatLng *position;

@end

NS_ASSUME_NONNULL_END
