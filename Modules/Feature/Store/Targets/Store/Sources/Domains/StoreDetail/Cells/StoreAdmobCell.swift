import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreAdmobCell: BaseCollectionViewCell {
    enum Layout {
        static let minimumHeight: CGFloat = 50
        static let horizontalInset: CGFloat = 20

        static func height(_ section: StoreAdmobSection) -> CGFloat {
            guard let card = section.cards.first else { return minimumHeight }
            return max(minimumHeight, CGFloat(card.height))
        }
    }

    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .storeDetail)
    private var hasLoadedAd = false

    override func prepareForReuse() {
        super.prepareForReuse()
        hasLoadedAd = false
    }

    override func setup() {
        contentView.addSubview(adBannerView)
    }

    override func bindConstraints() {
        adBannerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalInset)
            $0.height.equalTo(Layout.minimumHeight)
        }
    }

    func bind(_ section: StoreAdmobSection, rootViewController: UIViewController, isDisplayed: Bool) {
        let height = Layout.height(section)
        adBannerView.snp.updateConstraints {
            $0.height.equalTo(height)
        }

        guard isDisplayed, hasLoadedAd.isNot else { return }
        hasLoadedAd = true
        let size = CGSize(width: UIUtils.windowBounds.width - Layout.horizontalInset * 2, height: height)
        adBannerView.load(in: rootViewController, size: size)
    }
}
