#import "NMFFoundation.h"

@protocol NMCClusteringKey;
@protocol NMCClusterMarkerUpdater;
@protocol NMCLeafMarkerUpdater;
@class NMCClusterer<__covariant KeyType : NSObject<NMCClusteringKey> *>;

NS_ASSUME_NONNULL_BEGIN

/**
 `NMCClusterer`를 생성하는 빌더 클래스. 클러스터링할 거리, 최소/최대 줌 레벨, 애니메이션 여부, 클러스터/단말
 클러스터/단말 마커 커스터미이징 등 기본적인 기능을 제공합니다. 복잡한 전략과 기능이 필요하다면
 `NMCComplexBuilder`를 사용해야 합니다.
 */
NMF_EXPORT
@interface NMCBuilder<__covariant KeyType : NSObject<NMCClusteringKey> *> : NSObject

/**
 클러스터링할 기준 거리. 클러스터에 추가된 두 데이터의 화면상 거리가 기준 거리보다 가깝다면
 클러스터링되어 하나의 마커로 나타납니다.
 
 기본값은 `NMC_DEFAULT_SCREEN_DISTANCE`입니다.
 */
@property (nonatomic, assign) double screenDistance;

/**
 클러스터링할 최소 줌 레벨. 카메라의 줌 레벨이 최소 줌 레벨보다 낮다면 두 데이터가 화면상 기준
 거리보다 가깝더라도 더 이상 클러스터링되지 않습니다. 예를 들어, 클러스터링할 최소 줌 레벨이 4라면, 카메라의
 줌 레벨을 3레벨 이하로 축소하더라도 4레벨의 클러스터가 더 이상 클러스터링되지 않고 그대로 유지됩니다.
 
 기본값은 `NMF_MIN_ZOOM`입니다.
 */
@property (nonatomic, assign) NSInteger minZoom;

/**
 클러스터링할 최대 줌 레벨. 카메라의 줌 레벨이 최대 줌 레벨보다 높다면 두 데이터가 화면상 기준
 거리보다 가깝더라도 더 이상 클러스터링되지 않습니다. 예를 들어, 클러스터링할 최대 줌 레벨이 16이라면,
 카메라의 줌 레벨을 17레벨 이상으로 확대하면 모든 데이터가 클러스터링되지 않고 낱개로 나타납니다. 따라서
 클러스터링할 최대 줌 레벨이 지도의 최대 줌 레벨보다 크거나 같다면 카메라를 최대 줌 레벨로 확대하더라도 일부
 데이터는 여전히 클러스터링된 채 더 이상 펼쳐지지 않을 수 있습니다.
 
 기본값은 `NMF_MAX_ZOOM`입니다.
 */
@property (nonatomic, assign) NSInteger maxZoom;

/**
 카메라 확대/축소시 클러스터가 펼쳐지는/합쳐지는 애니메이션을 적용할지 여부.
 
 기본값은 `YES`입니다.
 */
@property (nonatomic, assign) bool animate;

/**
 클러스터 마커의 정보를 `NMFMarker` 객체에 반영하는 업데이터.
 
 기본값은 `NMCDefaultClusterMarkerUpdater` 인스턴스입니다.
 */
@property (nonatomic, nonnull) id<NMCClusterMarkerUpdater> clusterMarkerUpdater;

/**
 단말 마커의 정보를 `NMFMarker` 객체에 반영하는 업데이터.
 
 기본값은 `NMCDefaultLeafMarkerUpdater` 인스턴스입니다.
 */
@property (nonatomic, nonnull) id<NMCLeafMarkerUpdater> leafMarkerUpdater;

/**
 `NMCClusterer` 객체를 생성합니다.
 
 @return `NMCClusterer` 객체.
 */
- (NMCClusterer<KeyType> * _Nonnull)build;

@end

NS_ASSUME_NONNULL_END
