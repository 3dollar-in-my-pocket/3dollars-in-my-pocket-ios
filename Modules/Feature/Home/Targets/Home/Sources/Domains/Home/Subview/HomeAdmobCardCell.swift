import UIKit

import Common
import Model

final class HomeAdmobCardCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width - 81, height: 152)
    }
    
    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .homeCard)
    
    override func setup() {
        adBannerView.layer.cornerRadius = 20
        adBannerView.layer.masksToBounds = true
        
        contentView.addSubview(adBannerView)
        adBannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(rootViewController: UIViewController) {
        adBannerView.load(in: rootViewController)
    }
}
