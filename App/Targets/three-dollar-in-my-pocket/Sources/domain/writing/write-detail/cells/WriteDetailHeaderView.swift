import UIKit

import DesignSystem

final class WriteDetailHeaderView: UICollectionReusableView {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 44)
    }
    
    private let stackView = UIStackView()
    
    private let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    private func setup() {
        stackView.addArrangedSubview(titleLabel)
        addSubview(stackView)
    }
    
    private func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func bind(type: HeaderType) {
        setTitleLabel()
        switch type {
        case .none, .category:
            break
            
        case .normal(let title):
            titleLabel.text = title
            
        case .option(let title):
            titleLabel.text = title
            setOptionLabel()
            
        case .multi(let title):
            titleLabel.text = title
            setOptionLabel()
            setMultiLabel()
        }
    }
    
    private func setTitleLabel() {
        stackView.addArrangedSubview(titleLabel)
    }
        
    private func setOptionLabel() {
        let optionLabel = UILabel()
        optionLabel.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        optionLabel.textColor = DesignSystemAsset.Colors.gray40.color
        optionLabel.text = ThreeDollarInMyPocketStrings.writeDetailStoreOption
        
        stackView.setCustomSpacing(4, after: titleLabel)
        stackView.addArrangedSubview(optionLabel)
    }
    
    private func setMultiLabel() {
        let multiSelectLabel = UILabel()
        multiSelectLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        multiSelectLabel.textColor = DesignSystemAsset.Colors.mainPink.color
        multiSelectLabel.text = ThreeDollarInMyPocketStrings.writeDetailStoreCanSelectMulti
        
        if let lastView = stackView.subviews.last {
            stackView.setCustomSpacing(8, after: lastView)
        }
        stackView.addArrangedSubview(multiSelectLabel)
    }
}

extension WriteDetailHeaderView {
    enum HeaderType {
        case none
        case normal(title: String)
        case option(title: String)
        case multi(title: String)
        case category
    }
}
