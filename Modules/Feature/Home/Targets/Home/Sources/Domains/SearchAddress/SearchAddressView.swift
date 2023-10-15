import UIKit

import Common
import DesignSystem
import Then

final class SearchAddressView: BaseView {
    private let navigationView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.backgroundColor = .white
    }
    
    let closeButton = UIButton().then {
        $0.setImage(Icons.close.image, for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = Strings.SearchAddress.title
        $0.font = Fonts.medium.font(size: 16)
        $0.textColor = Colors.gray100.color
    }
    
    private let inputBoxContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 9
    }
    
    let searchImage = UIImageView().then {
        $0.image = Icons.search.image.withTintColor(Colors.gray50.color)
    }
    
    let addressField = UITextField().then {
        $0.placeholder = Strings.SearchAddress.placeholder
        $0.textColor = Colors.systemBlack.color
        $0.font = Fonts.regular.font(size: 14)
    }
    
    let clearButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.deleteX.image.withTintColor(Colors.gray30.color), for: .normal)
        button.isHidden = true
        
        return button
    }()
    
    lazy var addressCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    
    override func setup() {
        backgroundColor = Colors.gray10.color
        addSubViews([
            navigationView,
            closeButton,
            titleLabel,
            inputBoxContainer,
            searchImage,
            addressField,
            clearButton,
            addressCollectionView
        ])
    }
    
    override func bindConstraints() {
        navigationView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(56)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(navigationView).offset(-16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(closeButton)
        }
        
        inputBoxContainer.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
            $0.top.equalTo(navigationView.snp.bottom).offset(16)
        }
        
        searchImage.snp.makeConstraints {
            $0.centerY.equalTo(inputBoxContainer)
            $0.leading.equalTo(inputBoxContainer).offset(16)
            $0.size.equalTo(24)
        }
        
        clearButton.snp.makeConstraints {
            $0.trailing.equalTo(inputBoxContainer).offset(-16)
            $0.centerY.equalTo(inputBoxContainer)
            $0.size.equalTo(20)
        }
        
        addressField.snp.makeConstraints {
            $0.centerY.equalTo(inputBoxContainer)
            $0.leading.equalTo(searchImage.snp.trailing).offset(8)
            $0.trailing.equalTo(clearButton.snp.leading).offset(-8)
        }
        
        addressCollectionView.snp.makeConstraints {
            $0.top.equalTo(inputBoxContainer.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func showKeyboard() {
        self.addressField.becomeFirstResponder()
    }
    
    func hideKeyboard() {
        self.addressField.resignFirstResponder()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = AddressCell.Layout.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        return layout
    }
}
