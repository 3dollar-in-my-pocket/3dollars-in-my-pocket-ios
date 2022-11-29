import UIKit

import RxSwift
import RxCocoa

final class PhotoDetailView: BaseView {
    private let navigationView = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterialDark)
    ).then {
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        $0.layer.masksToBounds = true
    }
    
    let closeButton = UIButton().then {
        $0.setImage(R.image.ic_close_white(), for: .normal)
    }
  
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .semiBold(size: 16)
        $0.text = R.string.localization.photo_detail_title()
    }
  
    let deleteButton = UIButton().then {
        $0.setImage(R.image.ic_trash(), for: .normal)
    }
  
    let mainPhotoCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
        $0.register(
            PhotoMainCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoMainCollectionViewCell.registerId
        )
    }
  
    private let bottomBackgroundView = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterialDark)
    )
    
    let subPhotoCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.itemSize = PhotoSubCollectionViewCell.itemSize
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.register(
            PhotoSubCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoSubCollectionViewCell.registerId
        )
    }
    
    override func setup() {
        self.backgroundColor = .black
        self.addSubViews([
            self.mainPhotoCollectionView,
            self.navigationView,
            self.closeButton,
            self.titleLabel,
            self.deleteButton,
            self.bottomBackgroundView,
            self.subPhotoCollectionView
        ])
    }
  
    override func bindConstraints() {
        self.navigationView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(60)
        }
        
        self.closeButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalTo(self.titleLabel)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.navigationView).offset(-22)
        }
        
        self.deleteButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel)
            make.right.equalToSuperview().offset(-24)
        }
        
        self.mainPhotoCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        self.bottomBackgroundView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-110)
        }
        
        self.subPhotoCollectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.bottomBackgroundView).offset(24)
            make.height.equalTo(40)
        }
    }
    
    fileprivate func selectItem(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        DispatchQueue.main.async { [weak self] in
            self?.mainPhotoCollectionView.selectItem(
                at: indexPath,
                animated: false,
                scrollPosition: .centeredHorizontally
            )
            self?.subPhotoCollectionView.selectItem(
                at: indexPath,
                animated: true,
                scrollPosition: .left
            )
        }
    }
}

extension Reactive where Base: PhotoDetailView {
    var selectedIndex: Binder<Int> {
        return Binder(self.base) { view, index in
            view.selectItem(index: index)
        }
    }
}
