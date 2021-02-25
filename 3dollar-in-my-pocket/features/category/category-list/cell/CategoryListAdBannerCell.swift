import UIKit
import GoogleMobileAds

class CategoryListAdBannerCell: BaseTableViewCell {
  
  static let registerId = "\(CategoryListAdBannerCell.self)"
  
  let adBannerView = GADBannerView()
  
  
  override func setup() {
    self.contentView.isUserInteractionEnabled = false
    self.selectionStyle = .none
    self.addSubViews(adBannerView)
  }
  
  override func bindConstraints() {
    self.adBannerView.snp.makeConstraints { make in
      make.left.right.top.bottom.equalToSuperview()
      make.height.equalTo(80)
    }
  }
}
