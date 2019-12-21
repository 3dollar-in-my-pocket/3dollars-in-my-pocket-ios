import UIKit
import KakaoOpenSDK
import NaverThirdPartyLogin

class SignInVC: BaseVC {
    
    private lazy var signInView = SignInView(frame: self.view.frame)
    
    
    static func instance() -> SignInVC {
        return SignInVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = signInView
        bindEvent()
    }
    
    private func bindEvent() {
        signInView.kakaoBtn.rx.tap
            .bind(onNext: requestKakaoSignIn).disposed(by: disposeBag)
        
        signInView.naverBtn.rx.tap
            .bind(onNext: requestNaverSignIn).disposed(by: disposeBag)
        
    }
    
    private func requestKakaoSignIn() {
        guard let kakaoSession = KOSession.shared() else {
            AlertUtils.show(message: "Kakao session is null")
            return
        }
        
        if kakaoSession.isOpen() {
            kakaoSession.close()
        }
        
        kakaoSession.open { (error) in
            print("kakao session open call")
            if let error = error {
                AlertUtils.show(title: "error", message: error.localizedDescription)
            } else {
                AlertUtils.show(title: "success", message: kakaoSession.token?.accessToken)
            }
        }
    }
    
    private func requestNaverSignIn() {
        guard let connection = NaverThirdPartyLoginConnection.getSharedInstance() else {
            AlertUtils.show(title: "error", message: "네이버 로그인 초기화 실패")
            return
        }
        
        connection.delegate = self
        connection.requestThirdPartyLogin()
    }
}

extension SignInVC: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        guard let connection = NaverThirdPartyLoginConnection.getSharedInstance() else {
            AlertUtils.show(title: "error", message: "네이버 로그인 초기화 실패")
            return
        }
        AlertUtils.show(title: "success naver", message: connection.accessToken)
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        guard let connection = NaverThirdPartyLoginConnection.getSharedInstance() else {
            AlertUtils.show(title: "error", message: "네이버 로그인 초기화 실패")
            return
        }
        AlertUtils.show(title: "이미 연결되어있음", message: connection.accessToken)
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        AlertUtils.show(message: "oauth20ConnectionDidFinishDeleteToken()")
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        AlertUtils.show(title: "error", message: error.localizedDescription)
    }
}

