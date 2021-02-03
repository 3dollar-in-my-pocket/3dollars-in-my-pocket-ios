import RxSwift

class PhotoListVC: BaseVC {
  
  private lazy var photoListView = PhotoListView(frame: self.view.frame)
  private let viewModel: PhotoListViewModel
  
  
  init(storeId: Int, photos: [Image]) {
    self.viewModel = PhotoListViewModel(storeId: storeId, photos: photos)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(storeid: Int, photos: [Image]) -> PhotoListVC {
    return PhotoListVC(storeId: storeid, photos: photos)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = photoListView
    
    self.setupCollectionView()
    self.viewModel.fetchPhotos()
  }
  
  override func bindViewModel() {
    self.viewModel.output.photos.bind(to: self.photoListView.photoCollectionView.rx.items(
      cellIdentifier: PhotoListCell.registerId,
      cellType: PhotoListCell.self
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
    self.photoListView.photoCollectionView.register(
      PhotoListCell.self,
      forCellWithReuseIdentifier: PhotoListCell.registerId
    )
    
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
    )
    
    self.present(photoDetailVC, animated: false, completion: nil)
  }
}
