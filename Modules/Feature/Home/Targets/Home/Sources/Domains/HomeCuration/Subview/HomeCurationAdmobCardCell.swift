import UIKit

import Common
import Model

import SnapKit

final class HomeCurationAdmobCardCell: BaseCollectionViewCell {
    enum Layout {
        static func size(_ card: HomeListAdmobCardResponse, maxHeight: CGFloat) -> CGSize {
            let width = UIUtils.windowBounds.width - HomeCurationCarouselCell.Layout.horizontalInset * 2
            let height = min(HomeListAdmobCell.Layout.height(card), maxHeight)
            return CGSize(width: width, height: height)
        }
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
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize.zero)
        }
    }

    func bind(_ card: HomeListAdmobCardResponse, size: CGSize, rootViewController: UIViewController) {
        adBannerView.snp.updateConstraints {
            $0.size.equalTo(size)
        }
        adBannerView.isLoaded = false
        adBannerView.load(in: rootViewController, size: size)
    }
}
