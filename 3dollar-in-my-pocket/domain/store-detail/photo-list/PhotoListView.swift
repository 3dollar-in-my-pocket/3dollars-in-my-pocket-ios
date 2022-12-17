import UIKit

final class PhotoListView: BaseView {
    private let navigationView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        $0.backgroundColor = .white
    }
    
    let backButton = UIButton().then {
        $0.setImage(R.image.ic_back_black(), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = R.string.localization.photo_list_title()
        $0.textColor = .black
        $0.font = .semiBold(size: 16)
    }
    
    let photoCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = PhotoListCollectionViewCell.itemSize
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        $0.register(
            PhotoListCollectionViewCell.self,
          forCellWithReuseIdentifier: PhotoListCollectionViewCell.registerId
        )
    }
    
    override func setup() {
        self.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        self.addSubViews([
            self.navigationView,
            self.backButton,
            self.titleLabel,
            self.photoCollectionView
        ])
    }
    
    override func bindConstraints() {
        self.navigationView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(60)
        }
        
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalTo(self.titleLabel)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.navigationView).offset(-21)
        }
        
        self.photoCollectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.navigationView.snp.bottom)
        }
    }
}
