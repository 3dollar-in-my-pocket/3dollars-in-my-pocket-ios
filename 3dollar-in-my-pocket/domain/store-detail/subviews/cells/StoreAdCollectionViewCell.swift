import UIKit
import AppTrackingTransparency

import Base
import GoogleMobileAds

final class StoreAdCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(StoreAdCollectionViewCell.self)"
    static let height: CGFloat = 64
    
    let adBannerView = GADBannerView().then {
        $0.isHidden = true
        $0.adUnitID = Bundle.admobUnitId
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.adBannerView.delegate = nil
    }
    
    override func setup() {
        self.addSubViews([
            self.adBannerView
        ])
        self.contentView.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.loadAd()
    }
    
    override func bindConstraints() {
        self.adBannerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
            make.height.equalTo(64)
        }
    }
    
    private func loadAd() {
        let viewWidth = UIScreen.main.bounds.width
        
        self.adBannerView.adSize
        = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        self.adBannerView.delegate = self
        
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
            self.adBannerView.load(GADRequest())
        })
    }
}

extension StoreAdCollectionViewCell: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}

