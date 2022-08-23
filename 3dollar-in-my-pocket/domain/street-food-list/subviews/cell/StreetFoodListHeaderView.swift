import UIKit
import AppTrackingTransparency

import RxSwift
import RxCocoa
import GoogleMobileAds

final class StreetFoodListHeaderView: UICollectionReusableView {
    static let registerId = "\(StreetFoodListHeaderView.self)"
    static let height: CGFloat = 214
    
    var disposeBag = DisposeBag()
    
    private let categoryTitleLabel = UILabel().then {
        $0.font = .light(size: 24)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }
    
    let certificatedButton = CertificateButton()
    
    let orderFilterButton = OrderFilterButton(storeType: .streetFood)
    
    let adBannerView = GADBannerView().then {
        $0.adUnitID = Bundle.admobUnitId
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func bind(category: StreetFoodCategory) {
        let text = category.description
        let attributedString = NSMutableAttributedString(string: text)
        let boldTextRange = (text as NSString).range(of: category.name)
        
        attributedString.addAttribute(
            .font,
            value: UIFont.extraBold(size: 24)!,
            range: boldTextRange
        )
        attributedString.addAttribute(
            .kern,
            value: -1.2,
            range: .init(location: 0, length: text.count)
        )
        self.categoryTitleLabel.attributedText = attributedString
    }
    
    private func setup() {
        self.addSubViews([
            self.categoryTitleLabel,
            self.certificatedButton,
            self.orderFilterButton,
            self.adBannerView
        ])
        self.loadAd()
    }
    
    private func bindConstraints() {
        self.categoryTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(32)
        }
        
        self.certificatedButton.snp.makeConstraints { make in
            make.left.equalTo(self.categoryTitleLabel)
            make.top.equalTo(self.categoryTitleLabel.snp.bottom).offset(14)
        }
        
        self.orderFilterButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.certificatedButton)
            make.left.equalTo(self.certificatedButton.snp.right).offset(12)
        }
        
        self.adBannerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.certificatedButton.snp.bottom).offset(19)
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

extension Reactive where Base: StreetFoodListHeaderView {
    var category: Binder<StreetFoodCategory> {
        return Binder(self.base) { view, category in
            view.bind(category: category)
        }
    }
}

extension StreetFoodListHeaderView: GADBannerViewDelegate {
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
