import UIKit

import Common
import DesignSystem

final class UploadPhotoView: BaseView {
    private let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        return view
    }()
  
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.close.image.withTintColor(Colors.gray100.color).resizeImage(scaledTo: 24), for: .normal)
        
        return button
    }()
  
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MapDetail.title
        label.textColor = Colors.gray100.color
        label.font = Fonts.medium.font(size: 16)
        
        return label
    }()
  
    lazy var photoCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = Colors.gray0.color
        collectionView.contentInset = UIEdgeInsets(top: 28, left: 24, bottom: 28, right: 24)
        collectionView.allowsMultipleSelection = true
        collectionView.register([UploadPhotoCell.self])
        
        return collectionView
    }()
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.MapDetail.navigationButton, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 16)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.backgroundColor = Colors.gray30.color
        
        return button
    }()
    
    private let buttonBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray30.color
        
        return view
    }()
    
    override func setup() {
        backgroundColor = Colors.gray0.color
        addSubViews([
            photoCollectionView,
            topContainerView,
            closeButton,
            titleLabel,
            uploadButton,
            buttonBackgroundView
        ])
    }
    
    override func bindConstraints() {
        topContainerView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(56)
        }
        
        closeButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalTo(titleLabel)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(topContainerView).offset(-16)
        }
        
        photoCollectionView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(uploadButton.snp.top)
            $0.top.equalTo(topContainerView.snp.bottom)
        }
        
        uploadButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(buttonBackgroundView.snp.top)
            $0.height.equalTo(64)
        }
        
        buttonBackgroundView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func deselectCollectionItem(index: Int) {
        self.photoCollectionView.deselectItem(at: IndexPath(row: index, section: 0), animated: true)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = UploadPhotoCell.Layout.space
        layout.minimumLineSpacing = UploadPhotoCell.Layout.space
        layout.itemSize = UploadPhotoCell.Layout.itemSize
        return layout
    }
}
