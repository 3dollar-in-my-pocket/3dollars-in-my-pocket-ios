import UIKit

import Common
import Model

import SnapKit

final class FeedAdmobCardCell: BaseCollectionViewCell {
    enum Layout {
        static let minimumHeight: CGFloat = 50
        static let defaultHeight: CGFloat = 172

        static func height(_ card: HomeListAdmobCardResponse) -> CGFloat {
            guard let height = card.height else { return defaultHeight }
            return max(minimumHeight, CGFloat(height))
        }
    }

    var onClickAd: (() -> Void)?

    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .localNewsFeed)
    private var requestedAd: (cardId: String, width: CGFloat)?

    override func setup() {
        contentView.addSubview(adBannerView)
        adBannerView.onClick = { [weak self] in
            self?.onClickAd?()
        }
        adBannerView.onLoadFailed = { [weak self] in
            self?.requestedAd = nil
        }
    }

    override func bindConstraints() {
        adBannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func bind(card: HomeListAdmobCardResponse, width: CGFloat, rootViewController: UIViewController) {
        guard requestedAd?.cardId != card.cardId || requestedAd?.width != width else { return }
        requestedAd = (cardId: card.cardId, width: width)
        adBannerView.isLoaded = false
        adBannerView.setServerAdUnitId(card.adUnitId)
        adBannerView.load(in: rootViewController, size: CGSize(width: width, height: Layout.height(card)))
    }
}
