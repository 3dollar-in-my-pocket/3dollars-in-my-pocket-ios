import UIKit
import Common
import Model

final class FeedAdvertisementCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 60
    }
    
    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .localNewsFeed)
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(adBannerView)
        adBannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(advertisement: AdvertisementResponse?, rootViewController: UIViewController) {
        if let advertisement {
            adBannerView.isHidden = true
        } else {
            if adBannerView.isLoaded.isNot {
                adBannerView.load(in: rootViewController)
                adBannerView.isHidden = false
            }
        }
    }
}
