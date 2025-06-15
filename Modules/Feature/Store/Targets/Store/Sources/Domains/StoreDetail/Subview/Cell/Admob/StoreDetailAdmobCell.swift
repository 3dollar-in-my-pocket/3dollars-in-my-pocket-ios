import UIKit

import Common
import AppInterface
import DesignSystem

final class StoreDetailAdmobCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 49
    }
    
    let adBannerView: AdBannerViewProtocol = {
        let view = Environment.appModuleInterface.createAdBannerView(adType: .storeDetail)
        view.backgroundColor = DesignSystemAsset.Colors.gray0.color
        return view
    }()
    
    override func setup() {
        contentView.addSubview(adBannerView)
        adBannerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(viewModel: StoreDetailAdmobCellViewModel) {
        adBannerView.load(in: viewModel.output.rootViewController)
    }
}
