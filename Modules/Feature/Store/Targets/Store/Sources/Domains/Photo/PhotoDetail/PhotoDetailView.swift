import UIKit

import Common
import DesignSystem
import Model

final class PhotoDetailView: BaseView {
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.close.image.withTintColor(Colors.systemWhite.color), for: .normal)
        
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.register([PhotoDetailCell.self])
        collectionView.isPagingEnabled = true
        
        return collectionView
    }()
    
    let leftButton: UIButton = {
        let button = UIButton()
        button.setImage(
            Icons.arrowLeft.image.withTintColor(Colors.mainPink.color).resizeImage(scaledTo: 20),
            for: .normal
        )
        button.backgroundColor = Colors.gray95.color
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        
        return button
    }()
    
    let rightButton: UIButton = {
        let button = UIButton()
        button.setImage(
            Icons.arrowRight.image.withTintColor(Colors.mainPink.color).resizeImage(scaledTo: 20),
            for: .normal
        )
        button.backgroundColor = Colors.gray95.color
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        
        return button
    }()
    
    override func setup() {
        backgroundColor = Colors.gray100.color
        addSubViews([
            closeButton,
            collectionView,
            leftButton,
            rightButton
        ])
    }
    
    override func bindConstraints() {
        closeButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(closeButton.snp.bottom).offset(16)
            $0.bottom.equalTo(leftButton.snp.top).offset(-16)
        }
        
        leftButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.size.equalTo(44)
        }
        
        rightButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.size.equalTo(44)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = PhotoDetailCell.Layout.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        return layout
    }
}
