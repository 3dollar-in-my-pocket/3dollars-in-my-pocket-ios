import UIKit

import Common
import Model

final class HomeListAdmobCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 172
    }

    var onClickAd: (() -> Void)?

    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .homeCard)

    override func setup() {
        contentView.addSubview(adBannerView)
        adBannerView.onClick = { [weak self] in
            self?.onClickAd?()
        }
    }

    override func bindConstraints() {
        adBannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func bind(rootViewController: UIViewController) {
        adBannerView.isLoaded = false
        adBannerView.load(in: rootViewController)
    }
}
