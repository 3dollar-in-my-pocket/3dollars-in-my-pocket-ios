import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailVisitHistoryView: BaseView {
    enum Constant {
        static let moreButtonShowCount = 5
    }
    
    enum Layout {
        static let itemHeight: CGFloat = 18
        static let space: CGFloat = 4
        static let topPadding: CGFloat = 12
        static let bottomPadding: CGFloat = 12
        static func calculateHeight(count: Int) -> CGFloat {
            let itemHeight = itemHeight * CGFloat(count)
            
            var space: CGFloat = 0
            if count > 1 {
                space = Layout.space * CGFloat(count - 1)
            }
            
            let labelHeight: CGFloat = count > Constant.moreButtonShowCount ? 18 + 12 : 0
            
            return topPadding + bottomPadding + itemHeight + space + labelHeight
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
    
    private let moreVisitCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray50.color
        label.font = Fonts.medium.font(size: 12)
        label.textAlignment = .left
        
        return label
    }()
    
    
    override func setup() {
        containerView.addSubViews([
            stackView,
            moreVisitCountLabel
        ])
        addSubview(containerView)
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(moreVisitCountLabel)
        }
        
        stackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(12)
        }
        
        moreVisitCountLabel.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(28)
            $0.top.equalTo(stackView.snp.bottom).offset(12)
            $0.height.equalTo(0)
        }
    }
    
    func prepareForReuse() {
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        moreVisitCountLabel.text = nil
    }
    
    func bind(_ histories: [StoreVisitHistory], totalCount: Int) {
        setStackItem(histories, totalCount: totalCount)
    }
    
    private func setStackItem(_ histories: [StoreVisitHistory], totalCount: Int) {
        for history in histories {
            let stackItemView = StoreDetailVisitStackItemView(history: history)
            stackView.addArrangedSubview(stackItemView)
        }
        
        if totalCount > Constant.moreButtonShowCount {
            moreVisitCountLabel.isHidden = false
            moreVisitCountLabel.snp.updateConstraints {
                $0.height.equalTo(18)
            }
            moreVisitCountLabel.text = Strings.StoreDetail.Visit.moreFormat(totalCount - Constant.moreButtonShowCount)
        } else {
            moreVisitCountLabel.isHidden = true
            moreVisitCountLabel.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            moreVisitCountLabel.text = nil
        }
        
        containerView.snp.updateConstraints {
            $0.bottom.equalTo(moreVisitCountLabel).offset(histories.count > Constant.moreButtonShowCount ? 12 : 0)
        }
    }
}
