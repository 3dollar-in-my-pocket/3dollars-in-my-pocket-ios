import UIKit

import Base
import NMapsMap
import RxSwift
import RxDataSources


class ModifyVC: BaseVC {
  
  private lazy var modifyView = ModifyView(frame: self.view.frame)
  
  var store: Store
  var viewModel: ModifyViewModel
  var menuDataSource: RxTableViewSectionedReloadDataSource<MenuSection>!
  let marker = NMFMarker()
  
  init(store: Store) {
    self.store = store
    self.viewModel = ModifyViewModel(
      store: store,
      storeService: StoreService(),
      mapService: MapService()
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
    self.modifyView.menuTableView.removeObserver(self, forKeyPath: "contentSize")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(store: Store) -> ModifyVC {
    return ModifyVC.init(store: store).then {
      $0.hidesBottomBarWhenPushed = true
    }
  }
  
  override func viewDidLoad() {
    self.setupMenuTableView()
    self.setupCategoryCollectionView()
    self.setupKeyboardEvent()
    
    super.viewDidLoad()
    self.view = modifyView
    self.modifyView.bind(store: self.store)
    self.modifyView.scrollView.delegate = self
    self.addObservers()
    self.initilizeNaverMap()
    self.viewModel.fetchStore()
  }
  
  override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey : Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    if let obj = object as? UITableView {
      if obj == self.modifyView.menuTableView && keyPath == "contentSize" {
        self.modifyView.refreshMenuTableViewHeight()
      }
    }
  }
  
  override func bindViewModel() {
    // Bind input
    self.modifyView.storeNameField.rx.text.orEmpty
      .bind(to: self.viewModel.input.storeName)
      .disposed(by: disposeBag)
    
    self.modifyView.editButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .address_edit_button_clicked, page: .store_edit_page)
      })
      .bind(to: self.viewModel.input.tapEdit)
      .disposed(by: disposeBag)
    
    self.modifyView.dayStackView.sundayButton.rx.tap
      .map { WeekDay.sunday }
      .bind(to: self.viewModel.input.tapDay)
      .disposed(by: disposeBag)
    
    self.modifyView.dayStackView.mondayButton.rx.tap
      .map { WeekDay.monday }
      .bind(to: self.viewModel.input.tapDay)
      .disposed(by: disposeBag)
    
    self.modifyView.dayStackView.tuesdayButton.rx.tap
      .map { WeekDay.tuesday }
      .bind(to: self.viewModel.input.tapDay)
      .disposed(by: disposeBag)
    
    self.modifyView.dayStackView.wednesday.rx.tap
      .map { WeekDay.wednesday }
      .bind(to: self.viewModel.input.tapDay)
      .disposed(by: disposeBag)
    
    self.modifyView.dayStackView.thursday.rx.tap
      .map { WeekDay.thursday }
      .bind(to: self.viewModel.input.tapDay)
      .disposed(by: disposeBag)
    
    self.modifyView.dayStackView.friday.rx.tap
      .map { WeekDay.friday }
      .bind(to: self.viewModel.input.tapDay)
      .disposed(by: disposeBag)
    
    self.modifyView.dayStackView.saturday.rx.tap
      .map { WeekDay.saturday }
      .bind(to: self.viewModel.input.tapDay)
      .disposed(by: disposeBag)
    
    self.modifyView.storeTypeStackView.roadRadioButton.rx.tap
      .map { StreetFoodStoreType.road }
      .bind(to: self.viewModel.input.tapStoreType)
      .disposed(by: disposeBag)
    
    self.modifyView.storeTypeStackView.storeRadioButton.rx.tap
      .map { StreetFoodStoreType.store }
      .bind(to: self.viewModel.input.tapStoreType)
      .disposed(by: disposeBag)
    
    self.modifyView.storeTypeStackView.convenienceStoreRadioButton.rx.tap
      .map { StreetFoodStoreType.convenienceStore }
      .bind(to: self.viewModel.input.tapStoreType)
      .disposed(by: disposeBag)
    
    self.modifyView.paymentStackView.cashCheckButton.rx.tap
      .map { PaymentType.cash }
      .bind(to: self.viewModel.input.tapPaymentType)
      .disposed(by: disposeBag)
    
    self.modifyView.paymentStackView.cardCheckButton.rx.tap
      .map { PaymentType.card }
      .bind(to: self.viewModel.input.tapPaymentType)
      .disposed(by: disposeBag)
    
    self.modifyView.paymentStackView.transferCheckButton.rx.tap
      .map { PaymentType.transfer }
      .bind(to: self.viewModel.input.tapPaymentType)
      .disposed(by: disposeBag)
    
    self.modifyView.deleteAllButton.rx.tap
      .bind(to: self.viewModel.input.deleteAllCategories)
      .disposed(by: disposeBag)
    
    self.modifyView.registerButton.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .do(onNext: { _ in
        GA.shared.logEvent(event: .store_edit_submit_button_clicked, page: .store_edit_page)
      })
      .bind(to: self.viewModel.input.tapModify)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.address
      .bind(to: self.modifyView.addressLabel.rx.text)
      .disposed(by: disposeBag)
    
    self.viewModel.output.moveCamera
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.moveCamera)
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToEditAddress
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToEditAddress(store:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.storeNameIsEmpty
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.modifyView.setStoreNameBorderColoe(isEmpty:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.selectType
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.modifyView.storeTypeStackView.selectType(type:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.selectPaymentType
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.modifyView.paymentStackView.selectPaymentType(paymentTypes:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.selectDays
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.modifyView.dayStackView.selectDays(weekDays:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.categories
      .bind(to: self.modifyView.categoryCollectionView.rx.items(cellIdentifier: WriteCategoryCell.registerId, cellType: WriteCategoryCell.self)) { row, category, cell in
        cell.bind(category: category)
        self.modifyView.refreshCategoryCollectionViewHeight()
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.showCategoryDialog
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showCategoryDialog(selectedCategories:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.menus
      .do(onNext: self.modifyView.setMenuHeader)
      .bind(to: self.modifyView.menuTableView.rx.items(dataSource:self.menuDataSource))
      .disposed(by: disposeBag)
    
    self.viewModel.output.registerButtonIsEnable
      .bind(to: self.modifyView.registerButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    self.viewModel.output.popVC
      .observeOn(MainScheduler.instance)
      .bind(onNext: popupVC)
      .disposed(by: disposeBag)
    
    self.viewModel.output.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showRootLoading(isShow:))
      .disposed(by: disposeBag)
    
    self.viewModel.httpErrorAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showHTTPErrorAlert(error:))
      .disposed(by: disposeBag)
    
    self.viewModel.showSystemAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSystemAlert(alert:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.modifyView.bgTap.rx.event
      .bind { [weak self] (_) in
        self?.modifyView.endEditing(true)
      }.disposed(by: disposeBag)
    
    self.modifyView.backButton.rx.tap
      .observeOn(MainScheduler.instance)
      .do(onNext: { _ in
        GA.shared.logEvent(event: .back_button_clicked, page: .store_edit_page)
      })
      .bind(onNext: self.popupVC)
      .disposed(by: disposeBag)
  }
  
  private func addObservers() {
    self.modifyView.menuTableView.addObserver(
      self,
      forKeyPath: "contentSize",
      options: .new,
      context: nil
    )
  }
  
  private func popupVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func goToEditAddress(store: Store) {
    let modifyVC = ModifyAddressVC.instance(store: store).then {
      $0.delegate = self
    }
    
    self.navigationController?.pushViewController(modifyVC, animated: true)
  }
  
  private func setupCategoryCollectionView() {
    self.modifyView.categoryCollectionView.register(
      WriteCategoryCell.self,
      forCellWithReuseIdentifier: WriteCategoryCell.registerId
    )
    self.modifyView.categoryCollectionView.rx
      .setDelegate(self)
      .disposed(by: disposeBag)
    self.modifyView.categoryCollectionView.rx.itemSelected
      .bind { [weak self] indexPath in
        guard let self = self else { return }
        if indexPath.row == 0 {
          self.viewModel.input.tapAddCategory.onNext(())
        } else {
          self.viewModel.input.deleteCategory.onNext(indexPath.row - 1)
        }
      }
      .disposed(by: disposeBag)
  }
  
  private func setupMenuTableView() {
    self.modifyView.menuTableView.register(
      MenuCell.self,
      forCellReuseIdentifier: MenuCell.registerId
    )
    self.modifyView.menuTableView.rx
      .setDelegate(self)
      .disposed(by: disposeBag)
    self.menuDataSource = RxTableViewSectionedReloadDataSource<MenuSection> { (dataSource, tableView, indexPath, item) in
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: MenuCell.registerId,
        for: indexPath
      ) as? MenuCell else { return BaseTableViewCell() }
      
      cell.setMenu(menu: item)
      cell.nameField.rx.controlEvent(.editingDidEnd)
        .withLatestFrom(cell.nameField.rx.text.orEmpty)
        .map { (indexPath, $0) }
        .bind(to: self.viewModel.input.menuName)
        .disposed(by: cell.disposeBag)
        
      cell.descField.rx.controlEvent(.editingDidEnd)
        .withLatestFrom(cell.descField.rx.text.orEmpty)
        .map { (indexPath, $0) }
        .bind(to: self.viewModel.input.menuPrice)
        .disposed(by: cell.disposeBag)
        
      return cell
    }
  }
  
  private func setupKeyboardEvent() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onShowKeyboard(notification:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onHideKeyboard(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  private func showCategoryDialog(selectedCategories: [StoreCategory?]) {
    let addCategoryVC = AddCategoryVC.instance(selectedCategory: selectedCategories).then {
      $0.delegate = self
    }
    
    self.modifyView.showDim(isShow: true)
    self.present(addCategoryVC, animated: true, completion: nil)
  }
  
  private func initilizeNaverMap() {
    self.modifyView.mapView.positionMode = .direction
    self.modifyView.mapView.zoomLevel = 17
  }
  
  private func moveCamera(latitude: Double, longitude: Double) {
    marker.mapView = nil
    marker.position = NMGLatLng(lat: latitude, lng: longitude)
    marker.iconImage = NMFOverlayImage(name: "ic_marker")
    marker.mapView = self.modifyView.mapView
    
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude))
    self.modifyView.mapView.moveCamera(cameraUpdate)
  }
  
  private func markerWithSize(image:UIImage, scaledToSize newSize:CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
  }
  
  
  @objc func onShowKeyboard(notification: NSNotification) {
    let userInfo = notification.userInfo!
    var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    keyboardFrame = self.view.convert(keyboardFrame, from: nil)
    
    var contentInset:UIEdgeInsets = self.modifyView.scrollView.contentInset
    contentInset.bottom = keyboardFrame.size.height + 50
    self.modifyView.scrollView.contentInset = contentInset
  }
  
  @objc func onHideKeyboard(notification: NSNotification) {
    let contentInset:UIEdgeInsets = UIEdgeInsets.zero
    
    self.modifyView.scrollView.contentInset = contentInset
  }
}

extension ModifyVC: UIScrollViewDelegate {
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.modifyView.endEditing(true)
    self.modifyView.hideRegisterButton()
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      self.modifyView.showRegisterButton()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.modifyView.showRegisterButton()
  }
}


extension ModifyVC: AddCategoryDelegate {
  
  func onDismiss() {
    self.modifyView.showDim(isShow: false)
  }
  
  func onSuccess(selectedCategories: [StoreCategory]) {
    self.viewModel.input.addCategories.onNext(selectedCategories)
    self.modifyView.showDim(isShow: false)
  }
}


extension ModifyVC: UITableViewDelegate {
  func tableView(
    _ tableView: UITableView,
    viewForHeaderInSection section: Int
  ) -> UIView? {
    let menuHeaderView = MenuHeaderView().then {
      $0.frame = CGRect(
        x: 0,
        y: 0,
        width: tableView.frame.width,
        height: 56
      )
    }
    let sectionCategory = self.menuDataSource.sectionModels[section].category ?? .BUNGEOPPANG
    
    menuHeaderView.bind(category: sectionCategory)
    menuHeaderView.deleteButton.rx.tap
      .map { section }
      .subscribe(onNext: (self.viewModel.input.deleteCategory.onNext))
      .disposed(by: menuHeaderView.disposeBag)
    
    return menuHeaderView
  }
  
  func tableView(
    _ tableView: UITableView,
    heightForFooterInSection section: Int
  ) -> CGFloat {
    return 20
  }
  
  func tableView(
    _ tableView: UITableView,
    viewForFooterInSection section: Int
  ) -> UIView? {
    return MenuFooterView(frame: CGRect(
      x: 0,
      y: 0,
      width: tableView.frame.width,
      height: 20
    ))
  }
}

extension ModifyVC: ModifyAddressDelegate {
  func onModifyAddress(address: String, location: (Double, Double)) {
    self.modifyView.addressLabel.text = address
    self.viewModel.input.editLocation.onNext(location)
  }
}
