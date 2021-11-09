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
    self.viewModel = VisitViewModel(store: store)
    
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
    
  }
  
  override func bindViewModelOutput() {
    self.viewModel.output.store
      .asDriver(onErrorJustReturn: Store())
      .drive(self.visitView.rx.store)
      .disposed(by: self.disposeBag)
  }
}

extension VisitViewController: NMFMapViewCameraDelegate {
  
}
