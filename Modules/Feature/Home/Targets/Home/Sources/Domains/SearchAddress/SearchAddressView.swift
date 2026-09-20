import UIKit

import Common
import DesignSystem

final class SearchAddressView: BaseView {
    private let navigationView: UIView = {
        let navigationView = UIView()
        navigationView.layer.cornerRadius = 20
        navigationView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        navigationView.backgroundColor = .white
        return navigationView
    }()
    
    let closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.setImage(Icons.close.image, for: .normal)
        return closeButton
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = Strings.SearchAddress.title
        titleLabel.font = Fonts.medium.font(size: 16)
        titleLabel.textColor = Colors.gray100.color
        return titleLabel
    }()
    
    private let inputBoxContainer: UIView = {
        let inputBoxContainer = UIView()
        inputBoxContainer.backgroundColor = .white
        inputBoxContainer.layer.cornerRadius = 9
        return inputBoxContainer
    }()
    
    let searchImage: UIImageView = {
        let searchImage = UIImageView()
        searchImage.image = Icons.search.image.withTintColor(Colors.gray50.color)
        return searchImage
    }()
    
    let addressField: UITextField = {
        let addressField = UITextField()
        addressField.placeholder = Strings.SearchAddress.placeholder
        addressField.textColor = Colors.systemBlack.color
        addressField.font = Fonts.regular.font(size: 14)
        return addressField
    }()
    
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
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        return layout
    }
}
