import UIKit

class PhotoDetailView: BaseView {
  
  let navigationView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)).then {
    $0.layer.cornerRadius = 16
    $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    $0.layer.masksToBounds = true
  }
  
  let closeButton = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_close_white"), for: .normal)
  }
  
  let titleLabel = UILabel().then {
    $0.textColor = .white
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.text = "photo_detail_title".localized
  }
  
  let deleteButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_trash"), for: .normal)
  }
  
  let mainCollectionView = UICollectionView(
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
    $0.tag = 0
    $0.isPagingEnabled = true
  }
  
  let bottomBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
  
  let subCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = UICollectionViewFlowLayout()
    
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 40, height: 40)
    $0.collectionViewLayout = layout
    $0.backgroundColor = .clear
    $0.showsHorizontalScrollIndicator = false
    $0.tag = 1
    $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
  }
  
  
  override func setup() {
    self.backgroundColor = .black
    self.addSubViews(
      mainCollectionView, navigationView, closeButton, titleLabel,
      deleteButton, bottomBackgroundView, subCollectionView
    )
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
    
    self.mainCollectionView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    self.bottomBackgroundView.snp.makeConstraints { (make) in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-110)
    }
    
    self.subCollectionView.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.bottomBackgroundView).offset(24)
      make.height.equalTo(40)
    }
  }
}
