import UIKit

import Common
import AppInterface

final class PollDetailBannerCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 49)
    }
    
    private let adBannerView = Environment.appModuleInterface.createAdBannerView(adType: .pollDetail)
    
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
        adBannerView.load(in: rootViewController)
    }
}
