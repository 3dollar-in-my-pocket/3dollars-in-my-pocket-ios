import UIKit
import Common
import DesignSystem
import Model

final class BossStoreCouponCell: BaseCollectionViewCell {
    
    enum Layout {
        static func size(width: CGFloat, viewModel: BossStoreCouponViewModel) -> CGSize {
            return BossStoreCouponView.Layout.size(width: width, viewModel: viewModel)
        }
    }
    
    private let couponView = BossStoreCouponView()
    
    override func setup() {
        super.setup()
        
        backgroundColor = .clear
        
        contentView.addSubViews([
            couponView,
        ])
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        couponView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    func bind(viewModel: BossStoreCouponViewModel) {
        couponView.bind(viewModel: viewModel)
    }
}
