import UIKit

import DesignSystem

final class WriteDetailTypeCell: BaseCollectionViewCell {
    let typeStackView = WriteDetailTypeStackView()
    
    override func setup() {
        contentView.addSubview(typeStackView)
    }
    
    override func bindConstraints() {
        typeStackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}

extension WriteDetailTypeCell {
    final class WriteDetailTypeStackView: UIStackView {
        enum Layout {
            static let size = CGSize(width: 84, height: 36)
            static let space: CGFloat = 8
        }
        
        let roadRadioButton = TypeRadioButton(title: "·" + ThreeDollarInMyPocketStrings.storeTypeRoad)
        
        let storeRadioButton = TypeRadioButton(title: "·" + ThreeDollarInMyPocketStrings.storeTypeStore)
        
        let convenienceStoreRadioButton = TypeRadioButton(title: "·" + ThreeDollarInMyPocketStrings.storeTypeConvenienceStore)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.setup()
            self.bindConstraints()
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func selectType(type: StreetFoodStoreType?) {
            self.clearSelect()
            
            if let type = type {
                let index = type.getIndexValue()
                
                if let button = self.arrangedSubviews[index] as? UIButton {
                    button.isSelected = true
                }
            }
        }
        
        private func setup() {
            self.alignment = .leading
            self.axis = .horizontal
            self.backgroundColor = .clear
            self.distribution = .equalSpacing
            self.spacing = Layout.space
            
            self.addArrangedSubview(roadRadioButton)
            self.addArrangedSubview(storeRadioButton)
            self.addArrangedSubview(convenienceStoreRadioButton)
        }
        
        private func bindConstraints() {
            self.roadRadioButton.snp.makeConstraints {
                $0.size.equalTo(Layout.size)
            }
            
            self.storeRadioButton.snp.makeConstraints {
                $0.size.equalTo(Layout.size)
            }
            
            self.convenienceStoreRadioButton.snp.makeConstraints {
                $0.size.equalTo(Layout.size)
            }
        }
        
        private func clearSelect() {
            for subView in self.arrangedSubviews {
                if let button = subView as? UIButton {
                    button.isSelected = false
                }
            }
        }
    }
    
    final class TypeRadioButton: UIButton {
        override var isSelected: Bool {
            didSet {
                layer.borderColor = isSelected ? DesignSystemAsset.Colors.mainPink.color.cgColor : DesignSystemAsset.Colors.gray30.color.cgColor
            }
        }
        
        init(title: String) {
            super.init(frame: .zero)
            
            setupUI(title: title)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI(title: String) {
            setTitle("·" + title, for: .normal)
            titleLabel?.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)
            setTitleColor(DesignSystemAsset.Colors.gray40.color, for: .normal)
            setTitleColor(DesignSystemAsset.Colors.mainPink.color, for: .selected)
            layer.cornerRadius = 8
            layer.borderWidth = 1
            layer.borderColor = DesignSystemAsset.Colors.gray30.color.cgColor
        }
    }
}
