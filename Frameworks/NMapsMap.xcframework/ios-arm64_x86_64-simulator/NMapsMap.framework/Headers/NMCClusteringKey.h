#import "NMFFoundation.h"

@class NMGLatLng;

NS_ASSUME_NONNULL_BEGIN

/**
 클러스터링될 데이터의 키를 의미하는 인터페이스.
 
 클러스터러를 사용하고자 할 경우 이 인터페이스를 구현하는 클래스를 만들고, 그 타입을 `NMCClusterer`의 타입
 파라미터로 지정해야 합니다.
 
 `NMCClusterer`는 두 `NMCClusteringKey` 인스턴스가 동일하다면(equality) 동일한 데이터로 간주합니다.
 즉, 두 인스턴스의 좌표가 동일하더라도, `NSObject.isEqual:`가 `NO`라면 다른 데이터로 간주합니다.
 
 이 특성을 이용해 동일한 좌표에 위치하는 여러 데이터를 중복해서 클러스터링할 수 있으므로 이 언터페이스를 구현하는
 클래스는 `NSObject.isEqual:`와 `NSObject.hash:`도 구현하는 것이 권장됩니다.
 */
NMF_EXPORT
@protocol NMCClusteringKey<NSObject, NSCopying>

/**
 데이터의 좌표.
 */
@property (nonatomic, nonnull, readonly) NMGLatLng *position;

@end

NS_ASSUME_NONNULL_END
