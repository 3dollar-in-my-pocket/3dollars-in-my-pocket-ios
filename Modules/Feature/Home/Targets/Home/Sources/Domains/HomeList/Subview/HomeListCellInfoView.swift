import UIKit

import Common
import DesignSystem
import Model

final class HomeListCellInfoView: BaseView {
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    override func setup() {
        super.setup()
        
        addSubViews([
            stackView
        ])
    }
    
    override func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(stackView).priority(.high)
        }
    }
    
    func prepareForReuse() {
        stackView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func bind(storeCard: StoreCard) {
        let reviewItemView = HomeListInfoItemView(type: .review(storeCard.reviewsCount ?? 0))
        stackView.addArrangedSubview(reviewItemView)
        
        if storeCard.storeType == .userStore {
            let ratingItemView = HomeListInfoItemView(type: .rate(storeCard.rating ?? 0))
            addDividor()
            stackView.addArrangedSubview(ratingItemView)
        }
        
        let distanceItemView = HomeListInfoItemView(type: .distance(storeCard.distance))
        addDividor()
        stackView.addArrangedSubview(distanceItemView)
    }
    
    private func addDividor() {
        let containerView = UIView()
        let dividorView = UIView().then {
            $0.backgroundColor = DesignSystemAsset.Colors.gray50.color
        }
        
        containerView.addSubview(dividorView)
        containerView.snp.makeConstraints {
            $0.width.equalTo(1)
        }
        
        dividorView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(8)
            $0.centerY.equalToSuperview()
        }
        
        stackView.addArrangedSubview(containerView)
    }
}
