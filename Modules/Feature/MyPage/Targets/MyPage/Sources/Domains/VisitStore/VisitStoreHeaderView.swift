import UIKit

import Common
import DesignSystem
import Model

final class VisitStoreHeaderView: BaseCollectionViewReusableView {
    
    enum Layout {
        static let height: CGFloat = 18 + 12
    }
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.medium.font(size: 12)
        return label
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray80.color
        return view
    }()
    
    override func setup() {
        addSubViews([
            dateLabel,
            dividerView
        ])
    }
    
    override func bindConstraints() {
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        dividerView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalTo(dateLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(dateLabel)
        }
    }
    
    func bind(_ date: String) {
        dateLabel.text = date
    }
}
