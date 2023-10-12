import UIKit

import DesignSystem
import SnapKit

final class CategorySelectionHeaderView: UICollectionReusableView {
    static let registerId = "\(CategorySelectionHeaderView.self)"
    static let estimatedHeight: CGFloat = 64
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemBlack.color
        label.textAlignment = .left
        label.font = Fonts.bold.font(size: 16)
        
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
    
    private func setup() {
        addSubViews([titleLabel])
    }
    
    private func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func bind(title: String) {
        titleLabel.text = title
    }
}
