import UIKit
import Common
import Model

final class FeedAdvertisementCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 200
    }

    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .localNewsFeed)
    private weak var rootViewController: UIViewController?
    private var requestedAdWidth: CGFloat?

    override func setup() {
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        loadAdIfNeeded()
    }

    private func setupUI() {
        contentView.addSubview(adBannerView)
        adBannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func bind(advertisement: AdvertisementResponse?, rootViewController: UIViewController) {
        if advertisement != nil {
            adBannerView.isHidden = true
            self.rootViewController = nil
        } else {
            adBannerView.isHidden = false
            self.rootViewController = rootViewController
            if adBannerView.isLoaded.isNot {
                requestedAdWidth = nil
            }
            loadAdIfNeeded()
        }
    }

    private func loadAdIfNeeded() {
        guard let rootViewController else { return }
        let width = contentView.bounds.width
        guard width > 0, width != requestedAdWidth else { return }

        requestedAdWidth = width
        contentView.layoutIfNeeded()
        adBannerView.isLoaded = false
        adBannerView.load(in: rootViewController)
    }
}
