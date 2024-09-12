#import "NMFFoundation.h"

@class NMFMapView;

NS_ASSUME_NONNULL_BEGIN

/**
 타일 목록에 변경이 일어남에 대한 이벤트를 받을 델리게이트.
 */

@protocol NMFTileCoverHelperDelegate <NSObject>

/**
 타일 목록에 변경이 일어나면 호출되는 콜백 메서드.
 
 @param addedTileIds 화면에 추가된 타일 ID의 목록.
 @param removedTileIds 화면에서 제거된 타일 ID의 목록.
 */
- (void)onTileChanged:(NSArray<NSNumber *> * _Nullable)addedTileIds RemovedTileIds:(NSArray<NSNumber *> * _Nullable)removedTileIds;

@end

/**
 지도 화면을 커버하는 타일의 목록을 관리하며 변경이 일어나면 이벤트를 발생시키는 유틸리티 클래스.
 
 `NMFTileCoverHelperDelegate`로 델리게이트를 지정하고 `mapView` 속성에 대상 지도 객체를 지정하면 지도
 화면을 커버하는 타일의 목록이 변경될 때마다 `-onTileChanged::`가 호출됩니다. 화면에 추가된
 타일 영역에 대해서 데이터를 가져오고 제거된 타일 영역의 데이터는 제거하는 등의 작업을 할 경우, 이 클래스를 사용하면
 전체 타일 대신 변경사항이 있는 타일만을 처리하면 되므로 `-getCoveringTileIds`를 직접 사용하는 것에
 비해 효율적입니다.
 */
NMF_EXPORT
@interface NMFTileCoverHelper : NSObject

/**
 타일 목록에 변경이 일어남에 대한 이벤트를 받을 델리게이트 객체.
 */
@property(nonatomic, weak) id<NMFTileCoverHelperDelegate> delegate;

/**
 이벤트를 받아올 지도 객체.
 */
@property(nonatomic, weak) NMFMapView *mapView;

/**
 타일 목록을 갱신할 때 `-mapViewCameraIdle:` 대신 `-mapView:cameraIsChangingByReason:`을 사용할지 여부를 설정합니다.
 `-mapView:cameraIsChangingByReason:`을 사용하면 목록이 더 빠르게 갱신되지만 성능이 하락합니다.
 기본값 `NO`.
 */
@property(nonatomic) BOOL isUpdateOnChange;

/**
 최소 줌 레벨을 지정 합니다.
 기본값 `NMF_MIN_ZOOM`.
 */
@property(nonatomic) NSInteger minZoom;

/**
 최대 줌 레벨을 지정 합니다.
 기본값 `NMF_MAX_ZOOM`.
 */
@property(nonatomic) NSInteger maxZoom;

/**
 지도 객체를 지정하여 타일 커버 헬퍼를 생성합니다.
 
 @param mapView 지도 객체.
 */
+ (instancetype)tileCoverHelperWith:(NMFMapView * _Nonnull)mapView;

@end

NS_ASSUME_NONNULL_END
