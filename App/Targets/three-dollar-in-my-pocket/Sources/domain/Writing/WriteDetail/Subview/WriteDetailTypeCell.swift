import UIKit
import Combine

import DesignSystem

final class WriteDetailTypeCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    var tapPublisher: PassthroughSubject<StreetFoodStoreType, Never> {
        return typeStackView.tapPublisher
    }
    
    private let typeStackView = WriteDetailTypeStackView()
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
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
            static let height: CGFloat = 36
            static let space: CGFloat = 8
        }
        
        let tapPublisher = PassthroughSubject<StreetFoodStoreType, Never>()
        
        let roadRadioButton = TypeRadioButton(title: Strings.storeTypeRoad)
        
        let storeRadioButton = TypeRadioButton(title:Strings.storeTypeStore)
        
        let convenienceStoreRadioButton = TypeRadioButton(title: Strings.storeTypeConvenienceStore)
        
        var cancellables = Set<AnyCancellable>()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setup()
            bindConstraints()
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func selectType(type: StreetFoodStoreType?) {
            clearSelect()
            
            if let type = type {
                let index = type.getIndexValue()
                
                if let button = arrangedSubviews[index] as? UIButton {
                    button.isSelected = true
                }
            }
        }
        
        private func setup() {
            alignment = .center
            axis = .horizontal
            backgroundColor = .clear
            spacing = Layout.space
            distribution = .fillEqually
            
            addArrangedSubview(roadRadioButton)
            addArrangedSubview(storeRadioButton)
            addArrangedSubview(convenienceStoreRadioButton)
            
            roadRadioButton.controlPublisher(for: .touchUpInside)
                .withUnretained(self)
                .sink(receiveValue: { owner, _ in
                    owner.selectType(type: .road)
                    owner.tapPublisher.send(.road)
                })
                .store(in: &cancellables)
            
            storeRadioButton.controlPublisher(for: .touchUpInside)
                .withUnretained(self)
                .sink(receiveValue: { owner, _ in
                    owner.selectType(type: .store)
                    owner.tapPublisher.send(.store)
                })
                .store(in: &cancellables)
            
            convenienceStoreRadioButton.controlPublisher(for: .touchUpInside)
                .withUnretained(self)
                .sink(receiveValue: { owner, _ in
                    owner.selectType(type: .convenienceStore)
                    owner.tapPublisher.send(.convenienceStore)
                })
                .store(in: &cancellables)
        }
        
        private func bindConstraints() {
            roadRadioButton.snp.makeConstraints {
                $0.height.equalTo(Layout.height)
            }
            
            storeRadioButton.snp.makeConstraints {
                $0.height.equalTo(Layout.height)
            }
            
            convenienceStoreRadioButton.snp.makeConstraints {
                $0.height.equalTo(Layout.height)
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
                layer.borderColor = isSelected ? Colors.mainPink.color.cgColor : Colors.gray30.color.cgColor
                tintColor = isSelected ? Colors.mainPink.color : Colors.gray30.color
                dotImage.backgroundColor = isSelected ? Colors.mainPink.color : Colors.gray30.color
            }
        }
        
        let dotImage = UIView().then {
            $0.layer.cornerRadius = 3
            $0.backgroundColor = Colors.gray40.color
        }
        
        init(title: String) {
            super.init(frame: .zero)
            
            setupUI(title: title)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI(title: String) {
            setTitle(title, for: .normal)
            contentEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
            titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
            
            addSubview(dotImage)
            if let titleLabel = titleLabel {
                dotImage.snp.makeConstraints {
                    $0.centerY.equalTo(titleLabel)
                    $0.right.equalTo(titleLabel.snp.left).offset(-8)
                    $0.width.height.equalTo(6)
                }
            }

            tintColor = Colors.gray40.color
            titleLabel?.font = Fonts.Pretendard.semiBold.font(size: 14)
            setTitleColor(Colors.gray40.color, for: .normal)
            setTitleColor(Colors.mainPink.color, for: .selected)
            layer.cornerRadius = 8
            layer.borderWidth = 1
            layer.borderColor = Colors.gray30.color.cgColor
        }
    }
}
