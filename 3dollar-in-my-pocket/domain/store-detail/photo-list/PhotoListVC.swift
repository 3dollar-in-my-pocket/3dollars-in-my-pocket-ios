import UIKit

import RxSwift

class PhotoListVC: BaseVC {
  
  private lazy var photoListView = PhotoListView(frame: self.view.frame)
  private let viewModel: PhotoListViewModel
  
  
  init(storeId: Int) {
    self.viewModel = PhotoListViewModel(
      storeId: storeId,
      storeService: StoreService()
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(storeid: Int) -> PhotoListVC {
    return PhotoListVC(storeId: storeid)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = photoListView
    
    self.setupCollectionView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.viewModel.fetchPhotos()
  }
  
  override func bindViewModel() {
    self.viewModel.output.photos.bind(to: self.photoListView.photoCollectionView.rx.items(
      cellIdentifier: PhotoListCollectionViewCell.registerId,
      cellType: PhotoListCollectionViewCell.self
    )) { row, photo, cell in
      cell.bind(photo: photo)
    }
    .disposed(by: disposeBag)
    
    self.viewModel.output.showPhotoDetail
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showPhotoDetail)
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.photoListView.backButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.popVC)
      .disposed(by: disposeBag)
  }
  
  private func setupCollectionView() {
    self.photoListView.photoCollectionView.rx.itemSelected
      .map { $0.row }
      .bind(to: self.viewModel.input.tapPhoto)
      .disposed(by: disposeBag)
  }
  
  private func popVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func showPhotoDetail(storeId: Int, selectedIndex: Int, photos: [Image]){
    let photoDetailVC = PhotoDetailVC.instance(
      storeId: storeId,
      index: selectedIndex,
      photos: photos
    ).then {
      $0.delegate = self
    }
    
    self.present(photoDetailVC, animated: true, completion: nil)
  }
}

extension PhotoListVC: PhotoDetailDelegate {
  
  func onClose() {
    self.viewModel.fetchPhotos()
  }
}
