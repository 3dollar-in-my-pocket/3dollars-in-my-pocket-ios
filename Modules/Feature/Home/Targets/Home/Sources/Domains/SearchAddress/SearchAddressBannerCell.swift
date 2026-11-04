import UIKit

import Common
import AppInterface

final class SearchAddressBannerCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 49
    }
    
    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .searchAddress)
    
    override func setup() {
        contentView.addSubViews([
            adBannerView
        ])
    }
    
    override func bindConstraints() {
        adBannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(in rootViewController: UIViewController?) {
        guard let rootViewController else { return }
        layoutIfNeeded()
        adBannerView.load(in: rootViewController)
    }
}
