import UIKit

import Common

final class WebTabViewController: BaseViewController {
    private let webView = WebView(isNavigationBarHidden: true)
    private let url: URL

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.bind(url: url)
    }
}
