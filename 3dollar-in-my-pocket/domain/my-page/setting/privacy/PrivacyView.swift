import UIKit
import WebKit

class PrivacyView: BaseView {
    
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back_white"), for: .normal)
    }
    
    let titleLabel = UILabel().then {
        $0.text = "privacy_title".localized
        $0.textColor = .white
        $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    }
    
    let topLineView = UIView().then {
        $0.backgroundColor = UIColor(r: 43, g: 43, b: 43)
    }
    
    let webView = WKWebView()
    
    
    override func setup() {
        backgroundColor = UIColor(r: 28, g: 28, b: 28)
        addSubViews(backButton, titleLabel, topLineView, webView)
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24 * RatioUtils.widthRatio)
            make.top.equalTo(safeAreaLayoutGuide).offset(15)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.topLineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
        }
        
        self.webView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.topLineView.snp.bottom)
        }
    }
}
