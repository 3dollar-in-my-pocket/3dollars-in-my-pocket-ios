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
    
    let searchField = SearchField(
        leftIcon: Icons.search.image,
        placeholder: Strings.SearchAddress.placeholder
    )
    
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
            searchField,
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
            $0.trailing.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.bottom.equalTo(navigationView).offset(-16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalTo(safeAreaLayoutGuide)
            $0.centerY.equalTo(closeButton)
        }
        
        searchField.snp.makeConstraints {
            $0.leading.equalTo(safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.top.equalTo(navigationView.snp.bottom).offset(16)
        }
        
        addressCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchField.snp.bottom).offset(16)
            $0.leading.equalTo(safeAreaLayoutGuide)
            $0.trailing.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
    
    func showKeyboard() {
        searchField.textField.becomeFirstResponder()
    }
    
    func hideKeyboard() {
        searchField.textField.resignFirstResponder()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = WidthAdaptiveFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        return layout
    }
}
