import UIKit

import Common
import DesignSystem
import SnapKit

final class CategoryFilterHeaderView: BaseCollectionViewReusableView {
    enum Layout {
        static let estimatedHeight: CGFloat = 64
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.Colors.systemBlack.color
        label.textAlignment = .left
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
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        addSubViews([titleLabel])
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func bind(title: String, isFirst: Bool) {
        titleLabel.text = title
        if isFirst {
            titleLabel.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 20)
        } else {
            titleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        }
    }
}
