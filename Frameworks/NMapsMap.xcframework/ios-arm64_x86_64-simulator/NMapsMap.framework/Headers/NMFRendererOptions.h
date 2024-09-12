#import "NMFFoundation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 렌더러 유형.
 */
typedef NS_ENUM(NSInteger, NMFRendererType) {
    /**
     OpenGL ES 2.0.
     */
    NMFRendererTypeOpenGL,

    /**
     Metal.
     */
    NMFRendererTypeMetal
};

/**
 지도의 렌더링 관련 옵션을 지정하는 클래스. 지도 객체가 생성된 후에는 속성을 변경해도 지도에 적용되지 않습니다.
 이 클래스는 싱글턴 클래스로, `shared`를 이용해 인스턴스를 가져올 수 있습니다.
 */
NMF_EXPORT
@interface NMFRendererOptions : NSObject

/**
 싱글턴 인스턴스.
 */
@property (class, nonatomic, readonly, nonnull) NMFRendererOptions *shared;

/**
 지도 렌더러 유형을 지정하거나 반환합니다. 디바이스가 `NMFRendererTypeMetal`을 지원하지 않으면 `NMFRendererTypeOpenGL`이 지정됩니다.

 시뮬레이터에서 구동하는 경우의 기본값은 `NMFRendererTypeMetal`, 디바이스에서 구동하는 경우의 기본값은 `NMFRendererTypeOpenGL` 입니다.
 */
@property (nonatomic, assign) NMFRendererType rendererType;

/**
 4x MSAA를 적용할지 여부를 지정하거나 반환합니다.

 기본값은 `NO`입니다.
 */
@property (nonatomic, assign) BOOL msaa4x;

@end

NS_ASSUME_NONNULL_END
