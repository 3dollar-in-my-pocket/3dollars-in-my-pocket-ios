import UIKit
import WebKit

import Common
import DesignSystem
import Model

final class WebView: BaseView {
    let backButton: UIButton = {
        let button = UIButton()
        
        button.setImage(Assets.icBackWhite.image, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.semiBold.font(size: 16)
        return label
    }()
    
    private let topLineView: UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.gray80.color
        return view
    }()
    
    private let webView = WKWebView()

    private let requestBuilder = WebViewRequestBuilder()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = Colors.gray50.color
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func setup() {
        backgroundColor = Colors.gray90.color
        addSubViews([
            backButton,
            titleLabel,
            topLineView,
            webView,
            loadingIndicator
        ])
        webView.uiDelegate = self
        webView.navigationDelegate = self
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
            $0.top.equalTo(backButton.snp.bottom).offset(10)
        }
        
        webView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(topLineView.snp.bottom)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalTo(webView)
        }
    }
    
    func bind(title: String?, url: String) {
        titleLabel.text = title
        
        guard let url = URL(string: url) else { return }
        load(URLRequest(url: url))
    }
    
    func bind(webviewType: WebViewType) {
        titleLabel.text = webviewType.title

        guard let url = URL(string: webviewType.url) else { return }
        load(URLRequest(url: url))
    }

    private func load(_ request: URLRequest) {
        loadingIndicator.startAnimating()
        webView.customUserAgent = requestBuilder.customUserAgent(for: request.url)
        webView.load(requestBuilder.build(request: request))
    }
}

extension WebView: WKUIDelegate {
    // target="_blank" 링크는 새 창을 열 수 없어 무시되므로 현재 웹뷰에서 로드한다
    func webView(
        _ webView: WKWebView,
        createWebViewWith _: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures _: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame.isNil {
            load(navigationAction.request)
        }
        return nil
    }
}

extension WebView: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        let request = navigationAction.request
        guard navigationAction.targetFrame?.isMainFrame == true,
              requestBuilder.needsReload(request: request, currentUserAgent: webView.customUserAgent) else {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
        load(request)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}
