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
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.delete.image.withTintColor(Colors.gray60.color), for: .normal)
        
        return button
    }()
    
    override func setup() {
        backgroundColor = Colors.gray100.color
        addSubViews([
            closeButton,
            collectionView,
            leftButton,
            rightButton,
            deleteButton
        ])
    }
    
    override func bindConstraints() {
        closeButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.trailing.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.size.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalTo(safeAreaLayoutGuide)
            $0.trailing.equalTo(safeAreaLayoutGuide)
            $0.top.equalTo(closeButton.snp.bottom).offset(16)
            $0.bottom.equalTo(leftButton.snp.top).offset(-16)
        }
        
        leftButton.snp.makeConstraints {
            $0.leading.equalTo(safeAreaLayoutGuide).offset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.size.equalTo(44)
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.size.equalTo(44)
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerX.equalTo(safeAreaLayoutGuide)
            $0.centerY.equalTo(leftButton)
            $0.size.equalTo(24)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateItemSizeIfNeeded()
    }
    
    private func updateItemSizeIfNeeded() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let inset = collectionView.adjustedContentInset
        let itemSize = CGSize(
            width: collectionView.bounds.width - inset.left - inset.right,
            height: collectionView.bounds.height - inset.top - inset.bottom
        )
        guard itemSize.width > 0, itemSize.height > 0, layout.itemSize != itemSize else { return }
        
        layout.itemSize = itemSize
        layout.invalidateLayout()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        return layout
    }
}
