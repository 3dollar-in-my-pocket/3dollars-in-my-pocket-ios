import UIKit
import RxSwift
import NMapsMap

class WriteAddressVC: BaseVC {
  
  private lazy var writeAddressView = WriteAddressView(frame: self.view.frame)
  private let viewModel = WritingAddressViewModel()
  
  static func instance() -> UINavigationController {
    let writeAddressVC = WriteAddressVC(nibName: nil, bundle: nil)
    
    return UINavigationController(rootViewController: writeAddressVC).then {
      $0.modalPresentationStyle = .overCurrentContext
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = writeAddressView
    
    self.setupMap()
  }
  
  override func bindEvent() {
    self.writeAddressView.closeButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismiss)
      .disposed(by: disposeBag)
  }
  
  private func dismiss() {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func setupMap() {
    self.writeAddressView.mapView.positionMode = .direction
    self.writeAddressView.mapView.addCameraDelegate(delegate: self)
  }
}

extension WriteAddressVC: NMFMapViewCameraDelegate {
  
  func mapViewCameraIdle(_ mapView: NMFMapView) {
    let currentPosition = (mapView.cameraPosition.target.lat, mapView.cameraPosition.target.lng)
    
    self.viewModel.input.currentPosition.onNext(currentPosition)
  }
}
