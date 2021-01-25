import UIKit
import RxSwift
import NMapsMap

protocol ModifyDelegate: class {
  func onModifySuccess()
}

class ModifyVC: BaseVC {
  
  private lazy var modifyView = ModifyView(frame: self.view.frame)
  weak var delegate: ModifyDelegate?
  
  var store: Store!
  var viewModel = ModifyViewMode()
  var deleteVC: DeleteModalVC?
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  static func instance(store: Store) -> ModifyVC {
    return ModifyVC.init(nibName: nil, bundle: nil).then {
      $0.store = store
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = modifyView
    
    setupMenuTableView()
    setupKeyboardEvent()
    initilizeNaverMap()
  }
  
  override func bindViewModel() {
    modifyView.bgTap.rx.event.bind { [weak self] (_) in
      self?.modifyView.endEditing(true)
    }.disposed(by: disposeBag)
    
    self.modifyView.backButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .back_button_clicked, page: .store_edit_page)
      })
      .bind { [weak self] in
      self?.navigationController?.popViewController(animated: true)
    }.disposed(by: disposeBag)
    
    modifyView.registerBtn.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .do(onNext: { _ in
        GA.shared.logEvent(event: .store_edit_submit_button_clicked, page: .store_edit_page)
      })
      .bind { [weak self] in
//      guard let self = self else { return }
//
//      let storeId = self.store.id
//      let storeName = self.modifyView.nameField.text!
//      let images = self.viewModel.imageList
//      let latitude = self.modifyView.mapView.cameraPosition.target.lat
//      let longitude = self.modifyView.mapView.cameraPosition.target.lng
//      let menus = self.viewModel.menuList
//      let store = Store.init(
//        category: .BUNGEOPPANG,
//        latitude: latitude,
//        longitude: longitude,
//        storeName: storeName,
//        menus: menus
//      )
//
//      self.modifyView.showLoading(isShow: true)
//      StoreService().updateStore(storeId: storeId, store: store, images: images)
//        .subscribe(
//          onNext: { [weak self] _ in
//            self?.delegate?.onModifySuccess()
//            self?.navigationController?.popViewController(animated: true)
//            self?.modifyView.showLoading(isShow: false)
//          },
//          onError: { [weak self] error in
//            guard let self = self else { return }
//            if let httpError = error as? HTTPError {
//              self.showHTTPErrorAlert(error: httpError)
//            } else if let error = error as? CommonError {
//              let alertContent = AlertContent(title: nil, message: error.description)
//
//              self.showSystemAlert(alert: alertContent)
//            }
//            self.modifyView.showLoading(isShow: false)
//          })
//        .disposed(by: self.disposeBag)
    }
    .disposed(by: disposeBag)
  }
  
  private func setupMenuTableView() {
    viewModel.menuList = store.menus
    modifyView.menuTableView.delegate = self
    modifyView.menuTableView.dataSource = self
    modifyView.menuTableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.registerId)
  }
  
  private func setupKeyboardEvent() {
    NotificationCenter.default.addObserver(self, selector: #selector(onShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  private func initilizeNaverMap() {
    self.modifyView.mapView.positionMode = .direction
    
    let marker = NMFMarker()
    
    marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
    marker.iconImage = NMFOverlayImage(name: "ic_marker")
    marker.mapView = self.modifyView.mapView
    
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: store.latitude, lng: store.longitude))
    self.modifyView.mapView.moveCamera(cameraUpdate)
  }
  
  private func markerWithSize(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
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

extension ModifyVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.menuList.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.registerId, for: indexPath) as? MenuCell else {
      return BaseTableViewCell()
    }
    
    if indexPath.row < self.viewModel.menuList.count {
      cell.setMenu(menu: self.viewModel.menuList[indexPath.row])
    }
    
    cell.nameField.rx.controlEvent(.editingDidEnd).bind { [weak self] in
      let name = cell.nameField.text!
      let price = cell.descField.text
      
      if !name.isEmpty {
        let menu = Menu.init(name: name, price: price)
        
        if indexPath.row == self?.viewModel.menuList.count {
          self?.viewModel.menuList.append(menu)
          self?.modifyView.menuTableView.reloadData()
          self?.view.layoutIfNeeded()
        } else {
          self?.viewModel.menuList[indexPath.row].name = name
        }
      } else  {
        if let vc = self,
           indexPath.row < vc.viewModel.menuList.count,
           let _ = self?.viewModel.menuList[indexPath.row] {
          vc.viewModel.menuList.remove(at: indexPath.row)
        }
      }
    }.disposed(by: disposeBag)
    
    cell.descField.rx.controlEvent(.editingChanged).bind { [weak self] in
      let name = cell.nameField.text!
      let desc = cell.descField.text!
      
      if !name.isEmpty {
        let menu = Menu.init(name: name, price: desc)
        
        if let _ = self?.viewModel.menuList[indexPath.row] {
          self?.viewModel.menuList[indexPath.row] = menu
        }
      }
      
    }.disposed(by: disposeBag)
    return cell
  }
}
