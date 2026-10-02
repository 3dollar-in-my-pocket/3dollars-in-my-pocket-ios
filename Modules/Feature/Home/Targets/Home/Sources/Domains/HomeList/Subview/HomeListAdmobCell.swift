import UIKit

import Common
import Model

final class HomeListAdmobCell: BaseCollectionViewCell {
    enum Layout {
        static let minimumHeight: CGFloat = 50

        static func height(_ card: HomeListAdmobCardResponse) -> CGFloat {
            return max(minimumHeight, CGFloat(card.height))
        }
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

    func bind(_ card: HomeListAdmobCardResponse, rootViewController: UIViewController) {
        adBannerView.isLoaded = false
        let size = CGSize(width: UIUtils.windowBounds.width, height: Layout.height(card))
        adBannerView.load(in: rootViewController, size: size)
    }
}
