import UIKit
import RxSwift
import NMapsMap

class WriteAddressVC: BaseVC {
  
  private lazy var writeAddressView = WriteAddressView(frame: self.view.frame)
  private let viewModel = WriteAddressViewModel(mapService: MapService())
  
  static func instance() -> UINavigationController {
    let writeAddressVC = WriteAddressVC(nibName: nil, bundle: nil)
    
    return UINavigationController(rootViewController: writeAddressVC).then {
      $0.modalPresentationStyle = .overCurrentContext
      $0.isNavigationBarHidden = true
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = writeAddressView
    
    self.setupMap()
  }
  
  override func bindViewModel() {
    // Bind input
    self.writeAddressView.addressButton.rx.tap
      .bind(to: self.viewModel.input.tapSetAddressButton)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.addressText
      .bind(to: self.writeAddressView.addressLabel.rx.text)
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToWriteDetail
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToWriteDetail)
      .disposed(by: disposeBag)
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
  
  private func goToWriteDetail(address: String, location: (Double, Double)) {
    Log.debug("address: \(address)\nlocation: \(location)")
    let writingDetailVC = WritingVC.instance()
    
    self.navigationController?.pushViewController(writingDetailVC, animated: true)
  }
}

extension WriteAddressVC: NMFMapViewCameraDelegate {
  
  func mapViewCameraIdle(_ mapView: NMFMapView) {
    let currentPosition = (mapView.cameraPosition.target.lat, mapView.cameraPosition.target.lng)
    
    self.viewModel.input.currentPosition.onNext(currentPosition)
  }
}
