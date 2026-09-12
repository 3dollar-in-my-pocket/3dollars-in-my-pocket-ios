import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreAdmobCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 200
    }

    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .storeDetail)

    override func setup() {
        contentView.addSubview(adBannerView)
    }

    override func bindConstraints() {
        adBannerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(Layout.height)
        }
    }

    func bind(_ section: StoreAdmobSection, rootViewController: UIViewController) {
        adBannerView.load(in: rootViewController)
    }
}
