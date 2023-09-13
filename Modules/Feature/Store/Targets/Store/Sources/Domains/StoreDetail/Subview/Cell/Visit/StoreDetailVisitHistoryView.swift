import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailVisitHistoryView: BaseView {
    enum Layout {
        static let itemHeight: CGFloat = 18
        static let space: CGFloat = 4
        static func calculateHeight(count: Int) -> CGFloat {
            let itemHeight = itemHeight * CGFloat(count)
            let space = itemHeight * CGFloat(count - 1)
            let labelHeight: CGFloat = count > 5 ? 18 : 0
            
            return 24 + itemHeight + space + labelHeight
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 20
        
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.space
        
        return stackView
    }()
    
    private let visitCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray50.color
        label.font = Fonts.medium.font(size: 12)
        label.text = "+ 그 외 10명이 다녀갔어요!"
        
        return label
    }()
    
    
    override func setup() {
        containerView.addSubViews([
            stackView,
            visitCountLabel
        ])
        addSubview(containerView)
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(visitCountLabel).offset(12)
        }
        
        stackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(12)
        }
        
        visitCountLabel.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(28)
            $0.top.equalTo(stackView.snp.bottom).offset(12)
        }
    }
    
    func bind(_ histories: [StoreVisitHistory]) {
        isHidden = histories.isEmpty
        setStackItem(histories)
    }
    
    
    private func setStackItem(_ histories: [StoreVisitHistory]) {
        for history in histories {
            let stackItemView = StoreDetailVisitStackItemView(history: history)
            stackView.addArrangedSubview(stackItemView)
        }
        visitCountLabel.isHidden = histories.count > 5
    }
}
