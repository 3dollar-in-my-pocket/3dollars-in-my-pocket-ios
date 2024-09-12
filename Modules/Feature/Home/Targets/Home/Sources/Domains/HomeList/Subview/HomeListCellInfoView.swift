import UIKit

import Common
import DesignSystem
import Model

final class HomeListCellInfoView: BaseView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    override func setup() {
        super.setup()
        
        setupUI()
    }
    
    private func setupUI() {
        addSubViews([
            stackView
        ])
        
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
    
    func bind(_ storeWithExtra: StoreWithExtraResponse) {
        let reviewItemView = HomeListInfoItemView(type: .review(storeWithExtra.extra.reviewsCount ?? 0))
        stackView.addArrangedSubview(reviewItemView)
        
        if storeWithExtra.store.storeType == .userStore {
            let ratingItemView = HomeListInfoItemView(type: .rate(storeWithExtra.extra.rating ?? 0))
            addDivider()
            stackView.addArrangedSubview(ratingItemView)
        }
        
        let distanceItemView = HomeListInfoItemView(type: .distance(storeWithExtra.distanceM))
        addDivider()
        stackView.addArrangedSubview(distanceItemView)
    }
    
    private func addDivider() {
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
