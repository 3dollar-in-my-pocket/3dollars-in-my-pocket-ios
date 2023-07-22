import UIKit

import DesignSystem
import SnapKit
import Then

final class CategoryFilterHeaderView: UICollectionReusableView {
    static let registerId = "\(CategoryFilterHeaderView.self)"
    static let estimatedHeight: CGFloat = 64
    
    private let titleLabel = UILabel().then {
        $0.textColor = DesignSystemAsset.Colors.systemBlack.color
        $0.textAlignment = .left
    }
    
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
    
    func bind(title: String, isFirst: Bool) {
        titleLabel.text = title
        if isFirst {
            titleLabel.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 20)
        } else {
            titleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        }
    }
}
