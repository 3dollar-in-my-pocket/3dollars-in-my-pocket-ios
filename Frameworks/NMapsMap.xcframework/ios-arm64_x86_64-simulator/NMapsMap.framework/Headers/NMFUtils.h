#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <NMapsGeometry/NMapsGeometry.h>

#import "NMFMapView.h"

NS_INLINE CGFloat ScreenScaleFactor() {
    static dispatch_once_t onceToken;
    static CGFloat screenFactor;
    
    dispatch_once(&onceToken, ^{
        screenFactor = [UIScreen instancesRespondToSelector:@selector(nativeScale)] ?
                       [[UIScreen mainScreen] nativeScale] : [[UIScreen mainScreen] scale];
    });
    
    return screenFactor;
};

/**
 지오메트리 관련 유틸리티를 제공하는 클래스.
 */
NMF_EXPORT
@interface NMFGeometryUtils : NSObject

/**
 `NMGLatLng` 배열로 구성된 경로선에서 대상 좌표에 가장 근접한 지점의 진척률을 반환합니다.
 
 @param latLngs `NMGLatLng` 배열로 구성된 경로선.
 @param targetLatLng 대상 좌표.
 @return 진척률.
 */
+(double)progressWithLatLngs:(NSArray<NMGLatLng *> * _Nonnull)latLngs targetLatLng:(NMGLatLng * _Nonnull)targetLatLng;

/**
 `NMGLineString` 배열로 구성된 경로선에서 대상 좌표에 가장 근접한 지점의 진척률을 반환합니다.
 
 @param lineStrings `NMGLineString` 배열로 구성된 경로선.
 @param targetLatLng 대상 좌표.
 @return 진척률.
 */
+(double)progressWithLineStrings:(NSArray<NMGLineString *> * _Nonnull)lineStrings targetLatLng:(NMGLatLng * _Nonnull)targetLatLng;

@end


/**
 카메라 관련 유틸리티를 제공하는 클래스.
 */
NMF_EXPORT
@interface NMFCameraUtils : NSObject

/**
 `bounds`가 화면에 온전히 보이는 최대 줌 레벨을 반환합니다.
 
 @param bounds 영역.
 @param insets 영역과 지도 화면 간 확보할 인셋 여백. pt 단위.
 @param mapView `NMFMapView` 객체.
 @return `bounds`가 `map`에서 화면에 온전히 보이는 최대 줌 레벨.
 */
+ (double)getFittableZoomLevelWith:(NMGLatLngBounds * _Nonnull)bounds insets:(UIEdgeInsets)insets mapView:(NMFMapView * _Nonnull)mapView;
@end
