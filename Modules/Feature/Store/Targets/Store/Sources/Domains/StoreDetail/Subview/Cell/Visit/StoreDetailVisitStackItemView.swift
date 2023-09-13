import UIKit

import Common
import Model

final class StoreDetailVisitStackItemView: BaseView {
    enum Layout {
        static let height: CGFloat = 18
    }
    
    private let dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray50.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.bold.font(size: 12)
        label.textAlignment = .left
        
        return label
    }()
    
    init(history: StoreVisitHistory) {
        super.init(frame: .zero)
        bind(history)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        backgroundColor = .clear
        addSubViews([
            dotView,
            dateLabel,
            nameLabel
        ])
    }
    
    override func bindConstraints() {
        dotView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(4)
        }
        
        dateLabel.snp.makeConstraints {
            $0.left.equalTo(dotView.snp.right).offset(8)
            $0.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.left.equalTo(dateLabel.snp.right).offset(8)
            $0.right.lessThanOrEqualToSuperview()
            $0.height.equalTo(Layout.height)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bind(_ history: StoreVisitHistory) {
        dotView.backgroundColor = history.type == .exists ? Colors.mainGreen.color : Colors.mainRed.color
        nameLabel.text = history.name
    }
}
