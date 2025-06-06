#import "NMFFoundation.h"

@protocol NMCClusteringKey;
@protocol NMCThresholdStrategy;
@protocol NMCDistanceStrategy;
@protocol NMCPositioningStrategy;
@protocol NMCTagMergeStrategy;
@protocol NMCMarkerManager;
@protocol NMCClusterMarkerUpdater;
@protocol NMCLeafMarkerUpdater;
@class NMCClusterer<__covariant KeyType : NSObject<NMCClusteringKey> *>;

NS_ASSUME_NONNULL_BEGIN

/**
 `NMCClusterer`를 생성하는 빌더 클래스. 복잡한 전략과 기능을 제공합니다. 간단한 기능만 필요하다면
 `NMCBuilder`를 사용하는 것을 권장합니다.
 */
NMF_EXPORT
@interface NMCComplexBuilder<__covariant KeyType : NSObject<NMCClusteringKey> *> : NSObject

/**
 두 `NMCNode`를 클러스터링할 기준 거리를 구하는 전략.
 */
@property (nonatomic, nonnull) id<NMCThresholdStrategy> thresholdStrategy;

/**
 두 `NMCNode`간의 거리를 측정하는 전략.
 */
@property (nonatomic, nonnull) id<NMCDistanceStrategy> distanceStrategy;

/**
 두 `NMCCluster`의 좌표를 정하는 전략.
 */
@property (nonatomic, nonnull) id<NMCPositioningStrategy> positioningStrategy;

/**
 부모 `NMCCluster`의 자식 `NMCNode`들의 태그를 병합하는 전략.
 */
@property (nonatomic, nonnull) id<NMCTagMergeStrategy> tagMergeStrategy;

/**
 `NMCClusterer`에서 노출하는 마커를 관리하는 매니저.
 */
@property (nonatomic, nonnull) id<NMCMarkerManager> markerManager;

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
 클러스터링할 최소 줌 레벨. 카메라의 줌 레벨이 최소 줌 레벨보다 낮다면 두 데이터가 화면상 기준
 거리보다 가깝더라도 더 이상 클러스터링되지 않습니다. 예를 들어, 클러스터링할 최소 줌 레벨이 4라면, 카메라의
 줌 레벨을 3레벨 이하로 축소하더라도 4레벨의 클러스터가 더 이상 클러스터링되지 않고 그대로 유지됩니다.
 
 기본값은 `NMF_MIN_ZOOM`입니다.
 */
@property (nonatomic, assign) NSInteger minClusteringZoom;

/**
 클러스터링할 최대 줌 레벨. 카메라의 줌 레벨이 최대 줌 레벨보다 높다면 두 데이터가 화면상 기준
 거리보다 가깝더라도 더 이상 클러스터링되지 않습니다. 예를 들어, 클러스터링할 최대 줌 레벨이 16이라면,
 카메라의 줌 레벨을 17레벨 이상으로 확대하면 모든 데이터가 클러스터링되지 않고 낱개로 나타납니다. 따라서
 클러스터링할 최대 줌 레벨이 지도의 최대 줌 레벨보다 크거나 같다면 카메라를 최대 줌 레벨로 확대하더라도 일부
 데이터는 여전히 클러스터링된 채 더 이상 펼쳐지지 않을 수 있습니다.
 
 기본값은 `NMF_MAX_ZOOM` - `1`입니다.
 */
@property (nonatomic, assign) NSInteger maxClusteringZoom;

/**
 인덱싱할 최소 줌 레벨. 클러스터링할 최소 줌 레벨보다 작거나 같아야 합니다.
 
 `NMCClusterer`는 효율적인 클러스터링을 위해 공간 인덱스를 사용하는데 인덱스를 구축하는 데 자원이
 소모됩니다. 따라서 인덱싱할 최소 줌 레벨을 적절하게 제한하면 성능이 향상될 수 있습니다. 반면 과도하게
 제한하면 인덱싱할 줌 레벨 미만의 줌 레벨에서 렌더링 성능이 저하될 수 있습니다. 일반적으로 지도의 최소 줌
 레벨과 동일하게 지정할 때 가장 좋은 효율을 낼 수 있습니다.
 
 기본값은 `NMF_MIN_ZOOM`입니다.
 */
@property (nonatomic, assign) NSInteger minIndexingZoom;

/**
 인덱싱할 최대 줌 레벨을 반환합니다. 클러스터링할 최대 줌 레벨보다 크거나 같아야 합니다.
 
 `NMCClusterer`는 효율적인 클러스터링을 위해 공간 인덱스를 사용하는데 인덱스를 구축하는 데 자원이
 소모됩니다. 따라서 인덱싱할 최대 줌 레벨을 적절하게 제한하면 성능이 향상될 수 있습니다. 반면 과도하게
 제한하면 인덱싱할 줌 레벨을 초과하는 줌 레벨에서 렌더링 성능이 저하될 수 있습니다. 일반적으로 지도의 최대 줌
 레벨보다 `1` 작게 지정할 때 가장 좋은 효율을 낼 수 있습니다.
 
 기본값은 `NMF_MAX_ZOOM` - `1`입니다.
 */
@property (nonatomic, assign) NSInteger maxIndexingZoom;

/**
 클러스터링할 최대 화면 거리. 두 마커의 화면상 거리가 이 값보다 작을 경우에만 클러스터링 후보가
 됩니다. 즉, 두 마커의 화면상 거리가 이 값보다 크다면,
 `NMCDistanceStrategy.getDistance:Node1:Node2:`가 반환한 둘 간의 거리가
 `NMCThresholdStrategy.getThreshold:`보다 크더라도 클러스터링되지 않습니다. 한편 최대 화면 거리는 탐색
 공간을 제한하는 역할을 하므로 값을 크게 지정할수록 성능이 저하됩니다.
 
 따라서 `NMCDistanceStrategy`와 `NMCThresholdStrategy`를 별도로 지정했다면 전략을 고려해 적절한 값을
 지정해야 합니다. 예를 들어 `NMCDefaultDistanceStrategy`와 `NMCDefaultThresholdStrategy`를 사용한다면
 `NMCDefaultThresholdStrategy`의 생성자 파라메터로 지정한 거리와 동일한 값을 지정했을 때 가장 좋은 효율을
 낼 수 있습니다.
 
 기본값은 `NMC_DEFAULT_SCREEN_DISTANCE`입니다.
 */
@property (nonatomic, assign) double maxScreenDistance;

/**
 카메라 확대/축소시 클러스터가 펼쳐지는/합쳐지는 애니메이션의 지속 시간.`0`일 경우
 애니메이션이 적용되지 않습니다.

 기본값은 `NMC_DEFAULT_ANIMATION_DURATION`입니다.
 */
@property (nonatomic, assign) double animationDuration;

/**
 화면상 마커를 갱신할 때 `NMFMapViewCameraDelegate.mapViewCameraIdle:`대신
 `NMFMapViewCameraDelegate.mapView:cameraIsChangingByReason:`를 사용할지 여부.
 `NMFMapViewCameraDelegate.mapView:cameraIsChangingByReason:`를 사용하면
 더 빠르게 갱신되지만 성능이 하락합니다.
 
 기본값은 `NO`입니다.
 */
@property (nonatomic, assign) BOOL updateOnChange;

/**
 `NMCClusterer` 객체를 생성합니다.
 
 @return `NMCClusterer` 객체.
 */
- (NMCClusterer<KeyType> * _Nonnull)build;

@end

NS_ASSUME_NONNULL_END
