import UIKit
import WebKit

import Common
import DesignSystem
import Model

import SnapKit

final class StoreThreadPostCell: BaseCollectionViewCell {
    enum Layout {
        static let verticalMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 20
        static let headerSpacing: CGFloat = 4
        static let contentSpacing: CGFloat = 12
        static let cardSpacing: CGFloat = 12
        static let peekWidth: CGFloat = 36
        static let placeholderHeight: CGFloat = 400
        static let heightSettleDelay: TimeInterval = 0.3
    }

    var onHeightSettled: ((CGFloat) -> Void)?
    var onOpenURL: ((URL, SDClickLog?) -> Void)?

    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let subtitleLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 12))
    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.headerSpacing
        return stackView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.delegate = self
        return scrollView
    }()

    private let cardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = Layout.cardSpacing
        return stackView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var carouselHeightConstraint: Constraint?
    private lazy var collapsedConstraint: NSLayoutConstraint = {
        let constraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        constraint.priority = .required - 1
        return constraint
    }()
    private var loadedEmbeds: [StoreThreadPostEmbedSection.Embed] = []
    private var cardHeights: [String: CGFloat] = [:]
    private var failedPermalinks = Set<String>()
    private var heightSettleWorkItem: DispatchWorkItem?

    private var cardWidth: CGFloat {
        scrollView.bounds.width - Layout.horizontalMargin * 2 - Layout.peekWidth
    }

    override func setup() {
        contentView.clipsToBounds = true
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(subtitleLabel)
        contentView.addSubViews([headerStackView, scrollView, loadingIndicator])
        scrollView.addSubview(cardStackView)
    }

    override func bindConstraints() {
        headerStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.verticalMargin)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalMargin)
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom).offset(Layout.contentSpacing)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Layout.verticalMargin).priority(.high)
            carouselHeightConstraint = $0.height.equalTo(Layout.placeholderHeight).priority(.high).constraint
        }
        cardStackView.snp.makeConstraints {
            $0.top.bottom.equalTo(scrollView.contentLayoutGuide)
            $0.leading.equalTo(scrollView.contentLayoutGuide).offset(Layout.horizontalMargin)
            $0.trailing.equalTo(scrollView.contentLayoutGuide).offset(-Layout.horizontalMargin)
            $0.height.equalTo(scrollView.frameLayoutGuide)
        }
        loadingIndicator.snp.makeConstraints {
            $0.center.equalTo(scrollView)
        }
    }

    func bind(_ section: StoreThreadPostEmbedSection, height: CGFloat?, isDisplayed: Bool) {
        titleLabel.setSDText(section.header.title, lineHeight: 24)
        subtitleLabel.setSDText(section.header.subTitle, lineHeight: 18)
        subtitleLabel.isHidden = section.header.subTitle == nil

        let embeds = section.embeds
        updateHeight(embeds?.isEmpty == true ? 0 : height)
        if isDisplayed, let embeds, embeds.isEmpty.isNot, loadedEmbeds != embeds {
            loadCards(embeds)
        }
        updateLoadingIndicator(isCollapsed: embeds?.isEmpty == true)
    }

    private func updateHeight(_ height: CGFloat?) {
        let isCollapsed = height == 0
        headerStackView.isHidden = isCollapsed
        scrollView.isHidden = isCollapsed
        collapsedConstraint.isActive = isCollapsed
        if isCollapsed.isNot {
            carouselHeightConstraint?.update(offset: height ?? Layout.placeholderHeight)
        }
    }

    private func updateLoadingIndicator(isCollapsed: Bool) {
        let isWaitingForEmbeds = isCollapsed.isNot && cardStackView.arrangedSubviews.isEmpty
        if isWaitingForEmbeds {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }

    private func loadCards(_ embeds: [StoreThreadPostEmbedSection.Embed]) {
        loadedEmbeds = embeds
        cardHeights.removeAll()
        failedPermalinks.removeAll()
        heightSettleWorkItem?.cancel()
        cardStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        scrollView.setContentOffset(.zero, animated: false)

        embeds.forEach { embed in
            let cardView = ThreadPostEmbedCardView()
            cardView.onHeightChanged = { [weak self] height in
                self?.updateCardHeight(height, permalink: embed.permalink)
            }
            cardView.onLoadFailed = { [weak self, weak cardView] in
                cardView?.removeFromSuperview()
                self?.markLoadFailed(permalink: embed.permalink)
            }
            cardView.onOpenURL = { [weak self] url in
                self?.onOpenURL?(url, embed.clickLog)
            }
            cardStackView.addArrangedSubview(cardView)
            cardView.snp.makeConstraints {
                $0.width.equalTo(scrollView.frameLayoutGuide).offset(-(Layout.horizontalMargin * 2 + Layout.peekWidth))
            }
            cardView.load(html: embed.html)
        }
    }

    private func updateCardHeight(_ height: CGFloat, permalink: String) {
        guard failedPermalinks.contains(permalink).isNot else { return }
        cardHeights[permalink] = height
        scheduleHeightSettleIfReady()
    }

    private func markLoadFailed(permalink: String) {
        failedPermalinks.insert(permalink)
        cardHeights.removeValue(forKey: permalink)
        scheduleHeightSettleIfReady()
    }

    private func scheduleHeightSettleIfReady() {
        guard cardHeights.count + failedPermalinks.count >= loadedEmbeds.count else { return }
        heightSettleWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            onHeightSettled?(cardHeights.values.max() ?? 0)
        }
        heightSettleWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Layout.heightSettleDelay, execute: workItem)
    }
}

extension StoreThreadPostCell: UIScrollViewDelegate {
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let pageWidth = cardWidth + Layout.cardSpacing
        guard pageWidth > 0 else { return }
        let currentPage = scrollView.contentOffset.x / pageWidth
        let page: CGFloat
        if velocity.x > 0.2 {
            page = ceil(currentPage)
        } else if velocity.x < -0.2 {
            page = floor(currentPage)
        } else {
            page = round(currentPage)
        }
        let maxOffset = max(scrollView.contentSize.width - scrollView.bounds.width, 0)
        targetContentOffset.pointee.x = min(max(page * pageWidth, 0), maxOffset)
    }
}

private final class ThreadPostEmbedCardView: UIView {
    enum Layout {
        static let renderTimeout: TimeInterval = 10
        static let threadsOrigins = ["https://www.threads.com", "https://www.threads.net"]
        static let heightMessageName = "height"
        static let baseURL = URL(string: "https://threedollars.co.kr")
    }

    var onHeightChanged: ((CGFloat) -> Void)?
    var onLoadFailed: (() -> Void)?
    var onOpenURL: ((URL) -> Void)?

    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(
            WeakScriptMessageHandler(target: self),
            name: Layout.heightMessageName
        )
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.alpha = 0
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        return indicator
    }()

    private var heightConstraint: Constraint?
    private var renderTimeoutWorkItem: DispatchWorkItem?
    private var html: String?
    private var hasRendered = false
    private var hasFailed = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([webView, loadingIndicator])
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            heightConstraint = $0.height.equalTo(StoreThreadPostCell.Layout.placeholderHeight).priority(.high).constraint
        }
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        renderTimeoutWorkItem?.cancel()
    }

    func load(html: String) {
        self.html = html
        webView.loadHTMLString(Self.document(body: html), baseURL: Layout.baseURL)
        scheduleRenderTimeout()
    }

    private func scheduleRenderTimeout() {
        renderTimeoutWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self, hasRendered.isNot else { return }
            fail()
        }
        renderTimeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Layout.renderTimeout, execute: workItem)
    }

    private func fail() {
        guard hasFailed.isNot else { return }
        hasFailed = true
        renderTimeoutWorkItem?.cancel()
        loadingIndicator.stopAnimating()
        onLoadFailed?()
    }

    private static func document(body: String) -> String {
        let origins = Layout.threadsOrigins.map { "'\($0)'" }.joined(separator: ", ")
        return """
        <!doctype html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
        <style>html, body { margin: 0; padding: 0; background: transparent; }</style>
        </head>
        <body>
        <div id="root">\(body)</div>
        <script>
        (function() {
            var root = document.getElementById('root');
            var threadsOrigins = [\(origins)];
            var isEmbedRendered = false;
            var report = function() {
                if (!isEmbedRendered) { return; }
                window.webkit.messageHandlers.\(Layout.heightMessageName).postMessage(
                    Math.ceil(root.getBoundingClientRect().height)
                );
            };
            window.addEventListener('message', function(event) {
                if (threadsOrigins.indexOf(event.origin) < 0) { return; }
                isEmbedRendered = true;
                requestAnimationFrame(report);
            });
            new ResizeObserver(report).observe(root);
        })();
        </script>
        </body>
        </html>
        """
    }
}

extension ThreadPostEmbedCardView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard hasFailed.isNot, let value = message.body as? NSNumber else { return }
        let height = CGFloat(truncating: value)
        guard height > 0 else { return }
        hasRendered = true
        renderTimeoutWorkItem?.cancel()
        loadingIndicator.stopAnimating()
        webView.alpha = 1
        heightConstraint?.update(offset: height)
        onHeightChanged?(height)
    }
}

extension ThreadPostEmbedCardView: WKNavigationDelegate, WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
            onOpenURL?(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url {
            onOpenURL?(url)
        }
        return nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        fail()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        fail()
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        guard hasFailed.isNot, let html else { return }
        hasRendered = false
        webView.alpha = 0
        loadingIndicator.startAnimating()
        load(html: html)
    }
}

private final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var target: WKScriptMessageHandler?

    init(target: WKScriptMessageHandler) {
        self.target = target
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        target?.userContentController(userContentController, didReceive: message)
    }
}
