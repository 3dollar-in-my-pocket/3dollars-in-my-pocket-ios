import UIKit
import WebKit

import Common
import DesignSystem
import Model

final class WebView: Common.BaseView {
    let backButton: UIButton = {
        let button = UIButton()
        
        button.setImage(Assets.icBackWhite.image, for: .normal)
        return button
    }()
    
    private let titleLabel:  UILabel = {
        let label = UILabel()
        
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.semiBold.font(size: 16)
        return label
    }()
    
    private let topLineView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor(r: 43, g: 43, b: 43)
        return view
    }()
    
    private let webView = WKWebView()
    
    override func setup() {
        backgroundColor = UIColor(r: 28, g: 28, b: 28)
        addSubViews([
            backButton,
            titleLabel,
            topLineView,
            webView
        ])
    }
    
    override func bindConstraints() {
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(safeAreaLayoutGuide).offset(15)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        topLineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        webView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(topLineView.snp.bottom)
        }
    }
    
    func bind(title: String, url: String) {
        titleLabel.text = title
        
        guard let url = URL(string: url) else { return }
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
    
    func bind(webviewType: WebViewType) {
        titleLabel.text = webviewType.title
        
        guard let url = URL(string: webviewType.url) else { return }
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
}
