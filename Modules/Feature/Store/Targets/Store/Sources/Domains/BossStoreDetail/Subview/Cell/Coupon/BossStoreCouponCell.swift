import UIKit
import Common
import DesignSystem
import Model

final class BossStoreCouponCell: BaseCollectionViewCell {
    
    private static let sharedCell = BossStoreCouponCell()
    
    enum Layout {
        static let estimatedHeight: CGFloat = 100
        static func size(width: CGFloat, viewModel: BossStoreCouponViewModel) -> CGSize {
            
            sharedCell.bind(viewModel: viewModel)
            
            let size: CGSize = .init(width: width, height: UIView.layoutFittingCompressedSize.height)
            let cellSize = sharedCell.systemLayoutSizeFitting(
                size,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            return cellSize
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
