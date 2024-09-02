#import "NMFFoundation.h"
#import "NMCClustererUpdateCallback.h"

@protocol NMCClusteringKey;
@class NMFMapView;
@protocol NMCClusterMarkerUpdater;
@protocol NMCLeafMarkerUpdater;

/**
 두 마커가 인접했을 때 클러스터링될 기본 화면상 거리. pt 단위.
 */
const static double NMC_DEFAULT_SCREEN_DISTANCE = 70;

/**
 클러스터가 펼쳐지는/합쳐지는 애니메이션의 기본 지속 시간. 초 단위.
 */
const static double NMC_DEFAULT_ANIMATION_DURATION = 0.3;

NS_ASSUME_NONNULL_BEGIN

/**
 겹치는 여러 마커를 클러스터링해서 하나의 마커로 보여주는 기능을 제공하는 클래스. 이 클래스의 인스턴스는 직접 생성할
 수 없고 `NMCBuilder` 또는 `NMCComplexBuilder` 빌더 클래스를 이용해 생성해야 합니다. 여러 마커가 시각적으로
 겹치는 상황을 방지하는 기본적인 기능만 필요하다면 `NMCBuilder`를, 복잡한 전략과 기능이 필요하다면
 `NMCComplexBuilder`를 사용하는 것을 권장합니다.
 
 `NMCClusterer`를 사용하려면 먼저 데이터의 키를 의미하는 `NMCClusteringKey` 프로토콜을 구현한 클래스를
 정의해야 합니다. 이 클래스를 타입 파라메터로 지정해 `NMCClusterer` 인스턴스를 만들고,
 `add:Tag:` 또는 `addAll:`을 호출해 데이터를 추가한 후 `mapView`를
 이용해 지도 객체를 지정하면 지정한 데이터가 클러스터링되어 나타납니다.
 */
NMF_EXPORT
@interface NMCClusterer<__covariant KeyType : NSObject<NMCClusteringKey> *> : NSObject

/**
 클러스터를 `mapView`에 추가하거나, 클러스터가 추가된 지도 객체를 반환합니다.
 지도에 추가된 상태가 아닐 경우 `nil`을 반환합니다.
 */
@property (nonatomic, weak, nullable) NMFMapView *mapView;

/**
 데이터가 비어있는지 여부.
 */
@property (nonatomic, assign, readonly) BOOL empty;

- (instancetype)initWithThresholdStrategy:(id _Nonnull)thresholdStrategy
                         DistanceStrategy:(id _Nonnull)distanceStrategy
                      PositioningStrategy:(id _Nonnull)positioningStrategy
                         TagMergeStrategy:(id _Nonnull)tagMergeStrategy
                            MarkerManager:(id _Nonnull)markerManager
                     ClusterMarkerUpdater:(id _Nonnull)clusterMarkerUpdater
                        LeafMarkerUpdater:(id _Nonnull)leafMarkerUpdater
                        MinClusteringZoom:(NSInteger)minClusteringZoom
                        MaxClusteringZoom:(NSInteger)maxClusteringZoom
                          MinIndexingZoom:(NSInteger)minIndexingZoom
                          MaxIndexingZoom:(NSInteger)maxIndexingZoom
                        MaxScreenDistance:(double)maxScreenDistance
                        AnimationDuration:(double)animationDuration
                           UpdateOnChange:(BOOL)updateOnChange;

/**
 데이터에 `key`가 포함되어있는지 여부.
 
 @param key 포함 여부를 확인할 키.
 @return 포함되어있을 경우 `YES`, 그렇지 않을 경우 `NO`.
 */
- (BOOL)contains:(KeyType _Nonnull)key;

/**
 모든 데이터를 제거합니다.
 */
- (void)clear;

/**
 모든 데이터를 제거합니다.
 
 @param callback 데이터 제거가 완료되면 호출될 콜백.
 */
- (void)clearWithCallback:(NMCClustererUpdateCallback _Nullable)callback;

/**
 데이터를 추가합니다. 이 메서드를 여러 번 호출하면 지도에도 호출한 횟수만큼 나누어 반영됩니다. 따라서 여러
 데이터를 한 번에 추가하고자 할 경우 `addAll:`을 사용하면 성능이 향상됩니다.
 
 @param key 데이터의 키.
 @param tag 데이터의 태그.
 */
- (void)add:(KeyType _Nonnull)key :(NSObject * _Nullable)tag;

/**
 데이터를 추가합니다. 이 메서드를 여러 번 호출하면 지도에도 호출한 횟수만큼 나누어 반영됩니다. 따라서 여러
 데이터를 한 번에 추가하고자 할 경우 `addAll:`을 사용하면 성능이 향상됩니다.
 
 @param key 데이터의 키.
 @param tag 데이터의 태그.
 @param callback 데이터 추가가 완료되면 호출될 콜백.
 */
- (void)add:(KeyType _Nonnull)key :(NSObject * _Nullable)tag
   Callback:(NMCClustererUpdateCallback _Nullable)callback;

/**
 여러 데이터를 한 번에 추가합니다. 데이터를 한 번에 추가할 경우 지도에도 한 번에 반영됩니다.
 
 @param keyTagMap 키가 데이터의 키, 값이 데이터의 태그인 `NSDictionary`.
 */
- (void)addAll:(NSDictionary<KeyType, NSObject *> * _Nonnull)keyTagMap;

/**
 여러 데이터를 한 번에 추가합니다. 데이터를 한 번에 추가할 경우 지도에도 한 번에 반영됩니다.
 
 @param keyTagMap 키가 데이터의 키, 값이 데이터의 태그인 `NSDictionary`.
 @param callback 데이터 추가가 완료되면 호출될 콜백.
 */
- (void)addAll:(NSDictionary<KeyType, NSObject *> * _Nonnull)keyTagMap
      Callback:(NMCClustererUpdateCallback _Nullable)callback;

/**
 데이터를 제거합니다. 이 메서드를 여러 번 호출하면 지도에도 호출한 횟수만큼 나누어 반영됩니다. 따라서 여러
 데이터를 한 번에 제거하고자 할 경우 `removeAll:`을 사용하면 성능이 향상됩니다.
 */
- (void)remove:(KeyType _Nonnull)key;

/**
 데이터를 제거합니다. 이 메서드를 여러 번 호출하면 지도에도 호출한 횟수만큼 나누어 반영됩니다. 따라서 여러
 데이터를 한 번에 제거하고자 할 경우 `removeAll:`을 사용하면 성능이 향상됩니다.
 
 @param callback 데이터 제거가 완료되면 호출될 콜백.
 */
- (void)remove:(KeyType _Nonnull)key
      Callback:(NMCClustererUpdateCallback _Nullable)callback;

/**
 여러 데이터를 한 번에 제거합니다. 데이터를 한 번에 제거할 경우 지도에도 한 번에 반영됩니다.
 
 @param keys 제거할 키의 목록.
 */
- (void)removeAll:(NSArray * _Nonnull)keys;

/**
 여러 데이터를 한 번에 제거합니다. 데이터를 한 번에 제거할 경우 지도에도 한 번에 반영됩니다.
 
 @param keys 제거할 키의 목록.
 @param callback 데이터 제거가 완료되면 호출될 콜백.
 */
- (void)removeAll:(NSArray * _Nonnull)keys
         Callback:(NMCClustererUpdateCallback _Nullable)callback;

@end

NS_ASSUME_NONNULL_END
