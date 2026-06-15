import UIKit

import Common
import Model

final class HomeListAdmobCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 172
    }

    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .homeCard)

    override func setup() {
        contentView.addSubview(adBannerView)
    }

    override func bindConstraints() {
        adBannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func bind(rootViewController: UIViewController) {
        adBannerView.load(in: rootViewController)
    }
}
