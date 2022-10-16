import UIKit
import RxSwift

protocol PhotoDetailDelegate: class {
  func onClose()
}

class PhotoDetailVC: BaseVC {
  
  private lazy var photoDetailView = PhotoDetailView(frame: self.view.frame)
  private let viewModel: PhotoDetailViewModel
  weak var delegate: PhotoDetailDelegate?
  
  
  init(storeId: Int, index: Int, photos: [Image]) {
    self.viewModel = PhotoDetailViewModel(
      storeId: storeId,
      selectedIndex: index,
      photos: photos,
      storeService: StoreService(),
      globalState: GlobalState.shared
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(storeId: Int, index: Int, photos: [Image]) -> PhotoDetailVC {
    return PhotoDetailVC(storeId: storeId, index: index, photos: photos).then {
      $0.modalPresentationStyle = .overCurrentContext
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = photoDetailView
    self.setupCollectionView()
    self.viewModel.fetchPhotos()
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.output.mainPhotos
      .bind(to: self.photoDetailView.mainCollectionView.rx.items(
              cellIdentifier: PhotoMainCell.registerId,
              cellType: PhotoMainCell.self
      )) { row, image, cell in
        cell.bind(photo: image)
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.subPhotos
      .bind(to: self.photoDetailView.subCollectionView.rx.items(
              cellIdentifier: PhotoSubCell.registerId,
              cellType: PhotoSubCell.self
      )) { row, image, cell in
        cell.bind(photo: image)
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.selectPhoto
      .map { IndexPath(row: $0, section: 0) }
      .bind(onNext: self.selectItem(indexPath:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.dismiss
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismiss)
      .disposed(by: disposeBag)
    
    self.viewModel.output.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.photoDetailView.showLoading(isShow:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.photoDetailView.closeButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismiss)
      .disposed(by: disposeBag)
    
    self.photoDetailView.deleteButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showDeleteAlert)
      .disposed(by: disposeBag)
  }
  
  private func setupCollectionView() {
    self.photoDetailView.mainCollectionView.register(
      PhotoMainCell.self,
      forCellWithReuseIdentifier: PhotoMainCell.registerId
    )
    
    self.photoDetailView.mainCollectionView.rx.didScroll
      .map { _ -> IndexPath in
        let proportionalOffset = self.photoDetailView.mainCollectionView.contentOffset.x / self.view.frame.width
        return IndexPath(row: Int(proportionalOffset), section: 0)
      }
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.selectSubItem(indexPath:))
      .disposed(by: disposeBag)
    
    self.photoDetailView.subCollectionView.register(
      PhotoSubCell.self,
      forCellWithReuseIdentifier: PhotoSubCell.registerId
    )
    
    self.photoDetailView.subCollectionView.rx.itemSelected
      .observeOn(MainScheduler.instance)
      .bind(onNext: scrollToIndex(indexPath:))
      .disposed(by: disposeBag)
  }
  
  private func dismiss() {
    self.dismiss(animated: true, completion: nil)
    self.delegate?.onClose()
  }
  
  private func selectItem(indexPath: IndexPath) {
    self.photoDetailView.mainCollectionView.selectItem(
      at: indexPath,
      animated: false,
      scrollPosition: .centeredHorizontally
    )
    self.photoDetailView.subCollectionView.selectItem(
      at: indexPath,
      animated: true,
      scrollPosition: .left
    )
  }
  
  private func selectSubItem(indexPath: IndexPath){
    self.viewModel.input.selectPhoto.onNext(indexPath.row)
    self.photoDetailView.subCollectionView.selectItem(
      at: indexPath,
      animated: true,
      scrollPosition: .left
    )
  }
  
  private func scrollToIndex(indexPath: IndexPath) {
    self.viewModel.input.selectPhoto.onNext(indexPath.row)
    self.photoDetailView.mainCollectionView.selectItem(
      at: indexPath,
      animated: false,
      scrollPosition: .centeredHorizontally
    )
  }
  
  private func showDeleteAlert() {
    AlertUtils.showWithCancel(
      controller: self,
      title: "photo_detail_delete_title".localized,
      message: "photo_detail_delete_description".localized) {
      self.viewModel.input.tapDelete.onNext(())
    }
  }
}
