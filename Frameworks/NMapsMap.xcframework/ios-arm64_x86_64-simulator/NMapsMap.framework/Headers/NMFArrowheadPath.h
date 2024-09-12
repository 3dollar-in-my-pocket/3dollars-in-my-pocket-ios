#import <UIKit/UIKit.h>

#import "NMFOverlay.h"

NS_ASSUME_NONNULL_BEGIN

/**
 기본 화살표 경로 오버레이 전역 Z 인덱스
 */
const static int NMF_ARROWHEAD_PATH_OVERLAY_GLOBAL_Z_INDEX = 100000;

@class NMGLatLng;

/**
 화살표 형태로 방향 또는 회전 지점을 나타내는 오버레이. 경로선 오버레이와 마찬가지로 좌표열을 나타내지만 진척률을
 지정할 수 없고, 끝 지점에 삼각형 모양의 머리가 추가됩니다.
 */
NMF_EXPORT
@interface NMFArrowheadPath : NMFOverlay

/**
 색상.
 
 기본값은 `UIColor.whiteColor`입니다.
 */
@property(nonatomic, strong) UIColor *color;

/**
 외곽선의 색상. 외곽선의 색상은 반투명일 수 없으며, 완전히 투명하거나 완전히 불투명해야 합니다. 색상의
 알파가 `0`이 아닌 경우 완전히 불투명한 것으로 간주됩니다.
 
 기본값은 `UIColor.blackColor`입니다.
 */
@property(nonatomic, strong) UIColor *outlineColor;

/**
 좌표열. `points`의 크기는 `2` 이상이어야 합니다.
 */
@property(nonatomic, strong) NSArray<NMGLatLng *> *points;

/**
 두께. pt 단위.
 
 기본값은 `5`입니다.
 */
@property(nonatomic) CGFloat width;

/**
 외곽선의 두께. pt 단위.
 
 기본값은 `1`입니다.
 */
@property(nonatomic) CGFloat outlineWidth;

/**
 머리 크기의 배율을 반환합니다. 두께에 배율을 곱한 값이 머리의 크기가 됩니다.
 
 기본값은 `2.5`입니다.
 */
@property(nonatomic) CGFloat headSizeRatio;

/**
 높이. pt 단위.

 기본값은 `0`입니다.
 */
@property(nonatomic) CGFloat elevation;

/**
 좌표열을 지정하여 화살표 오버레이를 생성합니다. `points`의 크기는 `2` 이상이어야 합니다.

 @param points 좌표열.
 @return `NMFArrowheadPath` 객체.
 */
+ (nullable instancetype)arrowheadPathWith:(NSArray<NMGLatLng *>*)points;

@end

NS_ASSUME_NONNULL_END
