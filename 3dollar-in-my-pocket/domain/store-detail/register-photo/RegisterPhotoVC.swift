import Foundation
import UIKit

import RxSwift

protocol RegisterPhotoDelegate: class {
  func onSaveSuccess()
}

class RegisterPhotoVC: BaseVC {
  
  private lazy var registerPhotoView = RegisterPhotoView(frame: self.view.frame)
  private let viewModel: RegisterPhotoViewModel
  weak var delegate: RegisterPhotoDelegate?
  
  init(storeId: Int) {
    self.viewModel = RegisterPhotoViewModel(
      storeId: storeId,
      storeService: StoreService()
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(storeId: Int) -> RegisterPhotoVC {
    return RegisterPhotoVC(storeId: storeId).then {
      $0.modalPresentationStyle = .overCurrentContext
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = registerPhotoView
    
    self.setupPhotoCollectionView()
    self.viewModel.requestPhotosPermission()
  }
  
  override func bindViewModel() {
    // Bind input
    self.registerPhotoView.registerButton.rx.tap
      .bind(to: self.viewModel.input.tapRegisterButton)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.registerButtonIsEnable
      .bind(to: self.registerPhotoView.registerButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    self.viewModel.output.registerButtonText
      .bind(to: self.registerPhotoView.registerButton.rx.title(for: .normal))
      .disposed(by: disposeBag)
    
    self.viewModel.output.photos.bind(to: self.registerPhotoView.photoCollectionView.rx.items(
      cellIdentifier: RegisterPhotoCell.registerId,
      cellType: RegisterPhotoCell.self
    )) { row, asset, cell in
      cell.bind(asset: asset)
    }
    .disposed(by: disposeBag)
    
    self.viewModel.output.dismiss
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismissWithSuccess)
      .disposed(by: disposeBag)
    
    self.viewModel.output.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.registerPhotoView.showLoading(isShow:))
      .disposed(by: disposeBag)
    
    self.viewModel.httpErrorAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showHTTPErrorAlert(error:))
      .disposed(by: disposeBag)
  }
    
    override func bindViewModelOutput() {
        self.viewModel.output.deSelectPublisher
            .asDriver(onErrorJustReturn: -1)
            .drive(onNext: { [weak self] index in
                self?.registerPhotoView.deselectCollectionItem(index: index)
            })
            .disposed(by: self.disposeBag)
    }
  
  override func bindEvent() {
    self.registerPhotoView.closeButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismiss)
      .disposed(by: disposeBag)
  }
  
  private func setupPhotoCollectionView() {
    self.registerPhotoView.photoCollectionView.rx
      .setDelegate(self)
      .disposed(by: disposeBag)
  }
  
  private func dismiss() {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func dismissWithSuccess() {
    self.dismiss()
    self.delegate?.onSaveSuccess()
  }
}

extension RegisterPhotoVC: UICollectionViewDelegate {
  
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    if let cell = collectionView.cellForItem(at: indexPath) as? RegisterPhotoCell,
       let image = cell.photo.image {
      self.viewModel.input.selectPhoto.onNext((indexPath.row, image))
    }
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    didDeselectItemAt indexPath: IndexPath
  ) {
    if let cell = collectionView.cellForItem(at: indexPath) as? RegisterPhotoCell,
       let image = cell.photo.image {
      self.viewModel.input.selectPhoto.onNext((indexPath.row, image))
    }
  }
}

extension RegisterPhotoVC: UIScrollViewDelegate {
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.registerPhotoView.hideRegisterButton()
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      self.registerPhotoView.showRegisterButton()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.registerPhotoView.showRegisterButton()
  }
}
