import UIKit

import Base
import RxSwift

final class WebViewController: BaseViewController, WebViewCoordinator {
    private let webView = WebView()
    private weak var coordinator: WebViewCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance(webviewType: WebViewType) -> WebViewController {
        return WebViewController(webviewType: webviewType)
    }
    
    convenience init(webviewType: WebViewType) {
        self.init(nibName: nil, bundle: nil)
        self.webView.bind(webviewType: webviewType)
    }
    
    override func loadView() {
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.webView.backButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.presenter.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
    }
}
