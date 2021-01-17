import UIKit
import NMapsMap
import RxSwift

protocol WriteDetailDelegate: class {
  func onWriteSuccess(storeId: Int)
}

class WriteDetailVC: BaseVC {
  
  weak var deleagte: WriteDetailDelegate?
  
  private lazy var writeDetailView = WriteDetailView(frame: self.view.frame)
  let viewModel: WriteDetailViewModel
  
  
  init(address: String, location: (Double, Double)) {
    self.viewModel = WriteDetailViewModel(
      address: address,
      location: location,
      storeService: StoreService()
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(
    address: String,
    location: (Double, Double)
  ) -> WriteDetailVC {
    return WriteDetailVC(address: address, location: location)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = writeDetailView
    
    writeDetailView.scrollView.delegate = self
    setupCategoryCollectionView()
    setupKeyboardEvent()
    self.viewModel.fetchInitialData()
  }
  
  override func bindViewModel() {
    self.viewModel.output.address
      .bind(to: self.writeDetailView.locationValueLabel.rx.text)
      .disposed(by: disposeBag)
    
    self.viewModel.output.categories
      .bind(to: self.writeDetailView.categoryCollectionView.rx.items(cellIdentifier: WriteCategoryCell.registerId, cellType: WriteCategoryCell.self)) { row, category, cell in
        cell.bind(category: category)
        self.writeDetailView.refreshCategoryCollectionViewHeight()
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.showCategoryDialog
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showCategoryDialog(categories:))
      .disposed(by: disposeBag)
    
//    writingView.registerBtn.rx.tap
//      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
//      .do(onNext: { _ in
//        GA.shared.logEvent(event: .store_register_submit_button_clicked, page: .store_register_page)
//      })
//      .bind { [weak self] in
//        guard let self = self else { return }
//
//        let storeName = self.writingView.nameField.text!
//        let images = self.viewModel.imageList
//        let latitude = self.writingView.mapView.cameraPosition.target.lat
//        let longitude = self.writingView.mapView.cameraPosition.target.lng
//        let menus = self.viewModel.menuList
//
//        if let category = self.writingView.getCategory() {
//          let store = Store(
//            category: category,
//            latitude: latitude,
//            longitude: longitude,
//            storeName: storeName,
//            menus: menus
//          )
//
//          self.writingView.showLoading(isShow: true)
//          StoreService().saveStore(store: store, images: images).subscribe(
//            onNext: { [weak self] saveResponse in
//              guard let self = self else { return }
//
//              self.dismiss(animated: true, completion: nil)
//              self.deleagte?.onWriteSuccess(storeId: saveResponse.storeId)
//              self.writingView.showLoading(isShow: false)
//            },
//            onError: { [weak self] error in
//              guard let self = self else { return }
//              if let httpError = error as? HTTPError {
//                self.showHTTPErrorAlert(error: httpError)
//              } else if let error = error as? CommonError {
//                let alertContent = AlertContent(title: nil, message: error.description)
//
//                self.showSystemAlert(alert: alertContent)
//              }
//              self.writingView.showLoading(isShow: false)
//            })
//            .disposed(by: self.disposeBag)
//        }
//      }.disposed(by: disposeBag)
//
//    viewModel.btnEnable
//      .map { [weak self] (_) in
//        if let vc = self {
//          return !vc.writingView.nameField.text!.isEmpty && vc.writingView.getCategory() != nil
//        } else {
//          return false
//        }
//      }
//      .bind(to: writingView.registerBtn.rx.isEnabled)
//      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.writeDetailView.bgTap.rx.event
      .subscribe { [weak self] event in
        self?.writeDetailView.endEditing(true)
      }.disposed(by: disposeBag)
    
    self.writeDetailView.backButton.rx.tap
      .observeOn(MainScheduler.instance)
      .do(onNext: { _ in
        GA.shared.logEvent(event: .close_button_clicked, page: .store_register_page)
      })
      .bind(onNext: self.popupVC)
      .disposed(by: disposeBag)
  }
  
  private func popupVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func isValid(category: StoreCategory?, storeName: String) -> Bool {
    return category != nil && !storeName.isEmpty
  }
  
  private func setupCategoryCollectionView() {
    self.writeDetailView.categoryCollectionView.register(
      WriteCategoryCell.self,
      forCellWithReuseIdentifier: WriteCategoryCell.registerId
    )
    self.writeDetailView.categoryCollectionView.rx
      .setDelegate(self)
      .disposed(by: disposeBag)
    self.writeDetailView.categoryCollectionView.rx.itemSelected
      .bind { [weak self] indexPath in
        if indexPath.row == 0 {
          self?.viewModel.input.tapAddCategory.onNext(())
        }
      }
      .disposed(by: disposeBag)
  }
  
  private func setupKeyboardEvent() {
    NotificationCenter.default.addObserver(self, selector: #selector(onShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  private func showCategoryDialog(categories: [StoreCategory?]) {
    let addCategoryVC = AddCategoryVC.instance(selectedCategory: categories).then {
      $0.delegate = self
    }
    
    self.writeDetailView.showDim(isShow: true)
    self.present(addCategoryVC, animated: true, completion: nil)
  }
  
  @objc func onShowKeyboard(notification: NSNotification) {
    let userInfo = notification.userInfo!
    var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    keyboardFrame = self.view.convert(keyboardFrame, from: nil)
    
    var contentInset:UIEdgeInsets = self.writeDetailView.scrollView.contentInset
    contentInset.bottom = keyboardFrame.size.height + 50
    self.writeDetailView.scrollView.contentInset = contentInset
  }
  
  @objc func onHideKeyboard(notification: NSNotification) {
    let contentInset:UIEdgeInsets = UIEdgeInsets.zero
    
    self.writeDetailView.scrollView.contentInset = contentInset
  }
}

extension WriteDetailVC: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.writeDetailView.endEditing(true)
  }
}

extension WriteDetailVC: AddCategoryDelegate {
  
  func onDismiss() {
    self.writeDetailView.showDim(isShow: false)
  }
  
  func onSuccess(selectedCategories: [StoreCategory]) {
    Log.debug("selected categories: \(selectedCategories)")
    self.writeDetailView.showDim(isShow: false)
  }
}
