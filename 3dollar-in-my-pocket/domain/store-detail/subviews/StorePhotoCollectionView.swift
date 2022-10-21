import UIKit
import RxSwift

final class StorePhotoCollectionView: BaseView {
  
  var photoDisposeBag = DisposeBag()
  
  let titleLabel = UILabel().then {
    $0.textColor = R.color.black()
    $0.font = .semiBold(size: 18)
    $0.text = R.string.localization.store_detail_header_photo()
  }
  
  let countLabel = UILabel().then {
    $0.font = .medium(size: 16)
    $0.textColor = R.color.black()
  }
  
  let addPhotoButton = UIButton().then {
    $0.setTitle(R.string.localization.store_detail_header_add_photo(), for: .normal)
    $0.setTitleColor(R.color.red(), for: .normal)
    $0.titleLabel?.font = .bold(size: 12)
    $0.layer.cornerRadius = 15
    $0.backgroundColor = R.color.red()?.withAlphaComponent(0.2)
    $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
  }
  
  let photoCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = UICollectionViewFlowLayout()
    
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(
      width: (UIScreen.main.bounds.width - 75)/4,
      height: (UIScreen.main.bounds.width - 75)/4
    )
    layout.minimumInteritemSpacing = 9
    $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    $0.collectionViewLayout = layout
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.backgroundColor = .clear
  }
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews([
      self.titleLabel,
      self.countLabel,
      self.addPhotoButton,
      self.photoCollectionView
    ])
  }
  
  override func bindConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(46)
    }
    
    self.countLabel.snp.makeConstraints { make in
      make.left.equalTo(self.titleLabel.snp.right).offset(2)
      make.centerY.equalTo(self.titleLabel)
    }
    
    self.addPhotoButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview().offset(40)
    }
    
    self.photoCollectionView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalTo(self.titleLabel.snp.bottom).offset(18)
    }
    
    self.snp.makeConstraints { make in
      make.bottom.equalTo(self.photoCollectionView)
    }
  }
  
  func bind(store: Store) {
    self.countLabel.text = R.string.localization.store_detail_header_count(store.images.count)
    
    self.photoDisposeBag = DisposeBag()
    let photos = self.extractPhotos(from: store.images)
//    Observable.from(optional: photos)
//      .asDriver(onErrorJustReturn: [nil])
//      .drive(self.photoCollectionView.rx.items(
//              cellIdentifier: StoreDetailPhotoCell.registerId,
//              cellType: StoreDetailPhotoCell.self
//      )) { row, image, cell in
//        cell.bind(image: image, isLast: row == 3, count: store.images.count)
//      }
//      .disposed(by: self.photoDisposeBag)
  }
  
  private func extractPhotos(from photos: [Image]) -> [Image?] {
    if photos.isEmpty {
      return [nil]
    } else if photos.count <= 4 {
      return Array(photos[0..<photos.count])
    } else {
      return Array(photos[0..<4])
    }
  }
}
