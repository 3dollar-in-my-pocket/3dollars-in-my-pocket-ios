import UIKit
import KakaoOpenSDK

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
        signInView.kakaoBtn.rx.tap.bind { (_ ) in
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
            
        }.disposed(by: disposeBag)
    }
}

