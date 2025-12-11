import UIKit
import Common

final class HomeListAdmobCell: BaseCollectionViewCell {
    enum Layout {
        static let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
    }
    
    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .homeList)
    
    override func setup() {
        super.setup()
        
        contentView.addSubview(adBannerView)
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        adBannerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
    }
    
    func bind(rootViewController: UIViewController) {
        adBannerView.load(in: rootViewController)
    }
}

