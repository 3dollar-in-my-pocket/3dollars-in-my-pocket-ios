
#import <Foundation/Foundation.h>

/**
 네이버 클라우드 플랫폼 지도 API 인증 상태.
 */
typedef NS_ENUM(NSInteger, NMFAuthState) {
    /** 인증되지 않음. */
    NMFAuthStateUnauthorized = 0,
    /** 인증 진행 중. */
    NMFAuthStateAuthorizing,
    /** 인증 대기 중. */
    NMFAuthStatePending,
    /** 인증 완료. */
    NMFAuthStateAuthorized
};

/**
 인증 결과를 받는 델리게이트 프로토콜.
 */
@protocol NMFAuthManagerDelegate <NSObject>

/**
 인증이 성공했을 때 호출되는 콜백 메서드.
 
 @param state 인증 결과. 인증 결과는 `NMFAuthManager`에 저장됩니다.
 @param error 인증 결과가 실패일 때만 `NSError`가 지정됩니다.
 */
- (void)authorized:(NMFAuthState)state error:(nullable NSError *)error;

@end

/**
 인증 관리 기능을 담당하는 클래스. 이 클래스는 싱글턴으로, `shared`를
 이용해 인스턴스를 가져올 수 있습니다.
 
 네이버 지도 SDK를 사용하려면 반드시 클라이언트를 설정하고 인증 및 초기화를 수행해야 합니다. 클라이언트를
 설정하는 방법에는 두 가지가 있습니다.
 
    - 앱의 info.plist에 `NMFClientId`를 String으로 지정합니다.
    - 싱글턴 객체인 `shared`에서 `clientId`를 명시적으로 지정합니다.
 */
NMF_EXPORT
@interface NMFAuthManager : NSObject

/**
 NMFMapView를 사용하기 위한 API 인증 매니저 싱글턴.
 */
+ (nonnull instancetype)shared;

/**
 인증 결과를 받는 델리게이트 속성.
 */
@property(nonatomic, nullable, weak) id<NMFAuthManagerDelegate> delegate;

/**
 네이버 클라우드 플랫폼 인증을 위한 클라이언트 ID.
 */
@property(nonatomic, nullable) NSString *clientId;

/**
 공공기관용 네이버 클라우드 플랫폼 인증을 위한 클라이언트 ID.
 */
@property(nonatomic, nullable) NSString *govClientId;

/**
 API 인증 상태.
 */
@property(nonatomic, readonly) NMFAuthState authState;


@end
