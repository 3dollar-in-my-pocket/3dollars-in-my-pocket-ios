import UIKit

import Common
import Model
import DesignSystem

final class FaqCollectionHeaderView: UICollectionReusableView {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 90)
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = Colors.mainPink.color
        label.font = Fonts.semiBold.font(size: 20)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ faq: FaqResponse?) {
        titleLabel.text = faq?.categoryInfo.description
    }
    
    private func setup() {
        addSubViews([
            titleLabel
        ])
    }
    
    private func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(46)
            $0.centerX.equalToSuperview()
        }
    }
}
