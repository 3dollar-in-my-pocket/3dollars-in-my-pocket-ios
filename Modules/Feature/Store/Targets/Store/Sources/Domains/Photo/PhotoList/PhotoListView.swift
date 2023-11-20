import UIKit

import Common
import DesignSystem

final class PhotoListView: BaseView {
    private let topContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        
        return view
    }()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.arrowLeft.image.withTintColor(Colors.gray100.color), for: .normal)
        
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.PhotoList.title
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.gray100.color
        
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = Colors.gray0.color
        collectionView.register([PhotoListCell.self])
        collectionView.contentInset = .init(top: 12, left: 20, bottom: 12, right: 20)
        
        return collectionView
    }()
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.mainPink.color
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.setTitle(Strings.PhotoList.uploadButton, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 16)
        
        return button
    }()
    
    private let buttonBottomView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.mainPink.color
        
        return view
    }()
    
    override func setup() {
        addSubViews([
            topContainer,
            backButton,
            titleLabel,
            collectionView,
            uploadButton,
            buttonBottomView
        ])
    }
    
    override func bindConstraints() {
        topContainer.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(56)
        }
        
        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.bottom.equalTo(topContainer).offset(-16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalTo(topContainer)
            $0.centerY.equalTo(backButton)
        }
        
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(topContainer.snp.bottom)
            $0.bottom.equalTo(uploadButton.snp.top)
        }
        
        uploadButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(buttonBottomView.snp.top)
            $0.height.equalTo(64)
        }
        
        buttonBottomView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = PhotoListCell.Layout.size
        layout.minimumInteritemSpacing = PhotoListCell.Layout.itemSpace
        layout.minimumLineSpacing = PhotoListCell.Layout.itemSpace
        
        return layout
    }
}
