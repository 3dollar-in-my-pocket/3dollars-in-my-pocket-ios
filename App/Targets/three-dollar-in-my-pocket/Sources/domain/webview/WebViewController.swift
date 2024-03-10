import UIKit

import Common
import Model

final class WebViewController: Common.BaseViewController {
    private let webView = WebView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance(webviewType: WebViewType) -> WebViewController {
        return WebViewController(webviewType: webviewType)
    }
    
    convenience init(webviewType: WebViewType) {
        self.init(nibName: nil, bundle: nil)
        webView.bind(webviewType: webviewType)
    }
    
    convenience init(title: String, url: String) {
        self.init(nibName: nil, bundle: nil)
        
        webView.bind(title: title, url: url)
    }
    
    override func loadView() {
        view = webView
    }
    
    override func bindEvent() {
        webView.backButton.controlPublisher(for: .touchUpInside)
            .main
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
}
