import UIKit
import RxSwift

protocol DeleteModalDelegate: class {
  
  func onTapClose()
  func onRequest()
}

class DeleteModalVC: BaseVC {
  
  weak var deleagete: DeleteModalDelegate?
  
  private lazy var deleteModalView = DeleteModalView(frame: self.view.frame)
  private let viewModel: DeleteModalViewModel
  
  
  init(storeId: Int) {
    self.viewModel = DeleteModalViewModel(
      storeId: storeId,
      storeService: StoreService()
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(storeId: Int) -> DeleteModalVC {
    return DeleteModalVC(storeId: storeId).then {
      $0.modalPresentationStyle = .overCurrentContext
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = deleteModalView
  }
  
  override func bindViewModel() {
    // Bind input
    self.deleteModalView.deleteMenuStackView.notExistedButton.rx.tap
      .map { DeleteReason.NOSTORE }
      .bind(to: self.viewModel.input.tapReason)
      .disposed(by: disposeBag)
    
    self.deleteModalView.deleteMenuStackView.wrongContentButton.rx.tap
      .map { DeleteReason.WRONGCONTENT }
      .bind(to: self.viewModel.input.tapReason)
      .disposed(by: disposeBag)
    
    self.deleteModalView.deleteMenuStackView.overlapButton.rx.tap
      .map { DeleteReason.OVERLAPSTORE }
      .bind(to: self.viewModel.input.tapReason)
      .disposed(by: disposeBag)
    
    self.deleteModalView.deleteButton.rx.tap
      .do { _ in
        GA.shared.logEvent(event: .delete_request_submit_button_clicked, page: .delete_request_popup)
      }
      .bind(to: self.viewModel.input.tapDeleteButton)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.requestButtonIsEnable
      .bind(to: self.deleteModalView.deleteButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    self.viewModel.output.selectReason
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.deleteModalView.deleteMenuStackView.select(deleteReason:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.dismiss
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismissWhenRequest)
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
    self.deleteModalView.closeButton.rx.tap
      .do { _ in
        GA.shared.logEvent(
          event: .delete_request_popup_close_button_clicked,
          page: .delete_request_popup
        )
      }.bind(onNext: self.dismiss)
      .disposed(by: disposeBag)
    
    self.deleteModalView.tapBackground.rx.event
      .bind { [weak self] _ in
        self?.dismiss()
      }
      .disposed(by: disposeBag)
  }
  
  private func dismiss() {
    self.deleagete?.onTapClose()
    self.dismiss(animated: true, completion: nil)
  }
  
  private func dismissWhenRequest() {
    self.dismiss(animated: true, completion: nil)
    self.deleagete?.onRequest()
  }
}
