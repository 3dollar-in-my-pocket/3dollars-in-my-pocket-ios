#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NMFOverlay.h"
#import "NMFPathColor.h"

@class NMGLineString;
@class NMFOverlayImage;

NS_ASSUME_NONNULL_BEGIN

/**
 기본 멀티 파트 경로선 전역 Z 인덱스
 */
const static int NMF_MULTI_PART_PATH_OVERLAY_GLOBAL_Z_INDEX = -100000;

/**
 경로선을 여러 파트로 나누어 각각 다른 색상을 부여할 수 있는 특수한 `NMFPath`. 다양한 색상으로 구성된
 경로선을 나타내려면 여러 개의 `NMFPath`를 사용하는 것보다 이 클래스를 사용하는 것이 효율적입니다.
 `MultipartPathOverlay`는 좌표열 파트의 목록와 색상 파트의 목록으로 구성되며, `0`번째 좌표열 파트에
 `0`번째 색상 파트의 색상이 적용됩니다. 따라서 좌표열 파트와 색상 파트의 크기가 동일해야 합니다.
 */
NMF_EXPORT
@interface NMFMultipartPath : NMFOverlay

/**
 좌표열 파트의 목록. 목록의 크기가 `1`이상이어야 합니다.
 */
@property(nonatomic, strong) NSArray<NMGLineString *> *lineParts;

/**
 색상 파트의 목록. 목록의 크기가 `1` 이상, 각 파트의 크기가 `2` 이상이어야 합니다.
 */
@property(nonatomic, strong) NSArray<NMFPathColor *> *colorParts;

/**
 두께. pt 단위.
 
 기본값은 `5`입니다.
 */
@property(nonatomic) CGFloat width;

/**
 테두리 두께. pt 단위.
 
 기본값은 `1`입니다.
 */
@property(nonatomic) CGFloat outlineWidth;

/**
 진척률. 값의 범위는 `-1`~`1`입니다. 경로는 진척률을 기준으로 지나온 경로와 지나갈 경로로 구분됩니다. 지나온 경로에는
 `passedColor`와 `passedOutlineColor`가 사용되고 지나갈 경로에는 `color`와 `outlineColor`가 사용됩니다.

 - 진척률을 양수로 지정하면 첫 좌표부터 진척률만큼 떨어진 지점까지의 선형은 지나온 경로로, 나머지는 지나갈 경로로 간주됩니다.
 - 진척률을 음수로 지정하면 마지막 좌표부터 -진척률만큼 떨어진 지점까지의 선형은 지나온 경로로, 나머지는 지나갈 경로로 간주됩니다.
 - 진척률을 `0`으로 지정하면 모든 선형이 지나갈 경로로 간주됩니다.

 기본값은 `0`입니다.
 */
@property(nonatomic) double progress;

/**
 패턴 이미지의 간격. pt 단위. `0`일 경우 패턴을 표시하지 않습니다.
 
 기본값은 `25`입니다.
 */
@property(nonatomic) NSUInteger patternInterval;

/**
 패턴 이미지. 패턴 이미지의 크기가 경로선의 두께보다 클 경우 경로선의 두께에 맞게 축소됩니다.
 `nil`일 경우 패턴을 표시하지 않습니다.
 
 기본값은 `nil`입니다.
 */
@property(nonatomic, strong, nullable) NMFOverlayImage *patternIcon;

/**
 경로선과 지도 심벌이 겹칠 경우 지도 심벌을 숨길지 여부.
 
 기본값은 `NO`입니다.
 */
@property (nonatomic) BOOL isHideCollidedSymbols;

/**
 경로선과 마커가 겹칠 경우 마커를 숨길지 여부.
 
 기본값은 `NO`입니다.
 */
@property (nonatomic) BOOL isHideCollidedMarkers;

/**
 경로선과 마커의 캡션이 겹칠 경우 마커의 캡션을 숨길지 여부.
 
 기본값은 `NO`입니다.
 */
@property (nonatomic) BOOL isHideCollidedCaptions;

/**
 좌표열 파트의 목록을 지정하여 NMFMultipartPath 객체를 생성합니다.
 각 파트의 크기는 `2`이상이어야 합니다.
 
 ```
 NMFMultipartPath *mPath = [NMFMultipartPath multipartPathWithCoordParts:@[
    @[NMGLatLngMake(37.20, 127.051),
      NMGLatLngMake(37.21, 127.052),
      NMGLatLngMake(37.22, 127.053)],
    @[NMGLatLngMake(37.23, 127.054),
      NMGLatLngMake(37.24, 127.055),
      NMGLatLngMake(37.25, 127.056)]
 ]];
 mPath.mapView = mapView;
 ```
 
 @param coordParts 좌표열 파트의 목록.
 @return `NMFMultipartPath` 객체.
 */
+ (nullable instancetype)multipartPathWith:(NSArray<NSArray<NMGLatLng *> *> *)coordParts;

/**
 `NMGLineString`배열을 지정하여 NMFMultipartPath 객체를 생성합니다.
 배열내 `NMGLineString`객체의 `isValid` 속성이 `NO`일 경우 `nil`을 리턴합니다.
 
 @param lineParts `NMGLineString`파트의 목록.
 @return `NMFMultipartPath` 객체.
 */
+ (nullable instancetype)multipartPath:(NSArray<NMGLineString *> *)lineParts;

@end

NS_ASSUME_NONNULL_END

