import UIKit

import NMapsMap

final class VisitViewController: BaseVC, VisitCoordinator {
  private let visitView = VisitView()
  private let viewModel: VisitViewModel
  private weak var coordinator: VisitCoordinator?
  
  static func instance(store: Store) -> VisitViewController {
    return VisitViewController(store: store).then {
      $0.modalPresentationStyle = .fullScreen
    }
  }
  
  init(store: Store) {
    self.viewModel = VisitViewModel(
      store: store,
      locationManager: LocationManager.shared,
      visitHistoryService: VisitHistoryService()
    )
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    self.view = self.visitView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.coordinator = self
    self.visitView.mapView.addCameraDelegate(delegate: self)
    self.viewModel.input.viewDidLoad.onNext(())
  }
  
  override func bindEvent() {
    self.visitView.closeButton.rx.tap
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.coordinator?.dismiss()
      })
      .disposed(by: self.disposeBag)
  }
  
  override func bindViewModelInput() {
    self.visitView.currentLocationButton.rx.tap
      .bind(to: self.viewModel.input.tapCurrentLocationButton)
      .disposed(by: self.disposeBag)
    
    self.visitView.notExistedButton.rx.tap
      .map { VisitType.notExists }
      .bind(to: self.viewModel.input.tapVisitButton)
      .disposed(by: self.disposeBag)
    
    self.visitView.existedButton.rx.tap
      .map { VisitType.exists }
      .bind(to: self.viewModel.input.tapVisitButton)
      .disposed(by: self.disposeBag)
  }
  
  override func bindViewModelOutput() {
    self.viewModel.output.store
      .asDriver(onErrorJustReturn: Store())
      .drive(self.visitView.rx.store)
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.distance
      .asDriver(onErrorJustReturn: 0)
      .drive(onNext: { [weak self] distance in
        self?.visitView.bindDistance(distance: distance)
      })
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.isVisitable
      .asDriver(onErrorJustReturn: false)
      .drive { [weak self] isVisitable in
        self?.visitView.bindVisitable(isVisitable: isVisitable)
      }
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.moveCamera
      .asDriver(onErrorJustReturn: (0, 0))
      .drive { [weak self] (latitude, longitude) in
        self?.visitView.moveCamera(latitude: latitude, longitude: longitude)
      }
      .disposed(by: self.disposeBag)
    
    self.viewModel.output.dismiss
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        self?.coordinator?.dismissWithSuccessAlert()
      })
      .disposed(by: self.disposeBag)
    
    self.viewModel.showErrorAlert
      .asDriver(onErrorJustReturn: BaseError.unknown)
      .drive(onNext: { [weak self] error in
        self?.coordinator?.showErrorAlert(error: error)
      })
      .disposed(by: self.disposeBag)
  }
}

extension VisitViewController: NMFMapViewCameraDelegate {
  
}
