import UIKit
import NMapsMap
import RxSwift

protocol WriteDetailDelegate: class {
  func onWriteSuccess(storeId: Int)
}

class WriteDetailVC: BaseVC {
  
  weak var deleagte: WriteDetailDelegate?
  var viewModel = WriteDetailViewModel()
  var locationManager = CLLocationManager()
  
  private lazy var writeDetailView = WriteDetailView(frame: self.view.frame)
  
  private let imagePicker = UIImagePickerController()
  
  private var selectedImageIndex = 0
  
  
  static func instance() -> WriteDetailVC {
    return WriteDetailVC(nibName: nil, bundle: nil).then {
      $0.modalPresentationStyle = .fullScreen
    }
  }
  
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = writeDetailView
    
    writeDetailView.scrollView.delegate = self
    setupImageCollectionView()
    setupMenuTableView()
    setupKeyboardEvent()
    setupLocationManager()
    initilizeNaverMap()
  }
  
  override func bindViewModel() {
    writeDetailView.bgTap.rx.event.subscribe { [weak self] event in
      self?.writeDetailView.endEditing(true)
    }.disposed(by: disposeBag)
//
//    writingView.bungeoppangBtn.rx.tap.bind { [weak self] in
//      GA.shared.logEvent(event: .store_category_button_clicked, page: .store_register_page)
//      self?.writingView.tapCategoryBtn(index: 0)
//      self?.viewModel.btnEnable.onNext(())
//    }.disposed(by: disposeBag)
//
//    writingView.takoyakiBtn.rx.tap.bind { [weak self] in
//      GA.shared.logEvent(event: .store_category_button_clicked, page: .store_register_page)
//      self?.writingView.tapCategoryBtn(index: 1)
//      self?.viewModel.btnEnable.onNext(())
//    }.disposed(by: disposeBag)
//
//    writingView.gyeranppangBtn.rx.tap.bind { [weak self] in
//      GA.shared.logEvent(event: .store_category_button_clicked, page: .store_register_page)
//      self?.writingView.tapCategoryBtn(index: 2)
//      self?.viewModel.btnEnable.onNext(())
//    }.disposed(by: disposeBag)
//
//    writingView.hotteokBtn.rx.tap.bind { [weak self] in
//      GA.shared.logEvent(event: .store_category_button_clicked, page: .store_register_page)
//      self?.writingView.tapCategoryBtn(index: 3)
//      self?.viewModel.btnEnable.onNext(())
//    }.disposed(by: disposeBag)
//
//    writingView.nameField.rx.text.bind { [weak self] (inputText) in
//      self?.writingView.setFieldEmptyMode(isEmpty: inputText!.isEmpty)
//      self?.viewModel.btnEnable.onNext(())
//    }.disposed(by: disposeBag)
//
//    writingView.myLocationBtn.rx.tap.bind {
//      self.locationManager.startUpdatingLocation()
//    }.disposed(by: disposeBag)
//
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
  
  private func setupImageCollectionView() {
    imagePicker.delegate = self
//    writingView.imageCollection.isUserInteractionEnabled = true
//    writingView.imageCollection.dataSource = self
//    writingView.imageCollection.delegate = self
//    writingView.imageCollection.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.registerId)
  }
  
  private func setupMenuTableView() {
//    writingView.menuTableView.delegate = self
//    writingView.menuTableView.dataSource = self
//    writingView.menuTableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.registerId)
  }
  
  private func setupKeyboardEvent() {
    NotificationCenter.default.addObserver(self, selector: #selector(onShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  private func setupLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  private func initilizeNaverMap() {
//    self.writingView.mapView.positionMode = .direction
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

extension WriteDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.viewModel.imageList.count + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.registerId, for: indexPath) as? ImageCell else {
      return BaseCollectionViewCell()
    }
    
    if indexPath.row < self.viewModel.imageList.count {
      cell.setImage(image: self.viewModel.imageList[indexPath.row])
    } else {
      cell.setImage(image: nil)
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 104, height: 104)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedImageIndex = indexPath.row
    GA.shared.logEvent(event: .image_attach_button_clicked, page: .store_register_page)
    AlertUtils.showImagePicker(controller: self, picker: self.imagePicker)
  }
}

extension WriteDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[.originalImage] as? UIImage {
      let cropImage = ImageUtils.cropToBounds(image: image)
      
      if selectedImageIndex == self.viewModel.imageList.count {
        self.viewModel.imageList.append(cropImage)
      } else {
        self.viewModel.imageList[selectedImageIndex] = cropImage
      }
    }
//    self.writingView.imageCollection.reloadData()
    picker.dismiss(animated: true, completion: nil)
  }
}

extension WriteDetailVC: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.writeDetailView.endEditing(true)
  }
}

extension WriteDetailVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.menuList.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.registerId, for: indexPath) as? MenuCell else {
      return BaseTableViewCell()
    }
    
    cell.nameField.rx.controlEvent(.editingDidEnd).bind { [weak self] in
      let name = cell.nameField.text!
      let price = cell.descField.text
      
      if !name.isEmpty {
        let menu = Menu.init(name: name, price: price)
        
        if indexPath.row == self?.viewModel.menuList.count {
          self?.viewModel.menuList.append(menu)
//          self?.writingView.menuTableView.reloadData()
          self?.view.layoutIfNeeded()
        } else {
          self?.viewModel.menuList[indexPath.row].name = name
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
      } else  {
        if let vc = self,
           indexPath.row < vc.viewModel.menuList.count,
           let _ = self?.viewModel.menuList[indexPath.row] {
          vc.viewModel.menuList.remove(at: indexPath.row)
        }
      }
      
    }.disposed(by: disposeBag)
    
    return cell
  }
}

extension WriteDetailVC: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.last
    
    
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
      lat: location!.coordinate.latitude,
      lng: location!.coordinate.longitude
    ))
    cameraUpdate.animation = .easeIn
//    self.writingView.mapView.moveCamera(cameraUpdate)
    self.locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//    AlertUtils.show(title: "error locationManager", message: error.localizedDescription)
  }
}

