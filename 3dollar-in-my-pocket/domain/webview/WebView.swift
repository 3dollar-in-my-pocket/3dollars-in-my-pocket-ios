import UIKit
import WebKit

final class WebView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(R.image.ic_back_white(), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .semiBold(size: 16)
    }
    
    private let topLineView = UIView().then {
        $0.backgroundColor = UIColor(r: 43, g: 43, b: 43)
    }
    
    private let webView = WKWebView()
    
    override func setup() {
        self.backgroundColor = UIColor(r: 28, g: 28, b: 28)
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.topLineView,
            self.webView
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
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
    
    func bind(webviewType: WebViewType) {
        self.titleLabel.text = webviewType.title
        
        guard let url = URL(string: webviewType.url) else { return }
        let request = URLRequest(url: url)
        
        self.webView.load(request)
    }
}
