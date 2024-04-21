import Foundation

import Common
import DesignSystem
import Log

final class EditBookmarkViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let editBookmarkView = EditBookmarkView()
    private let viewModel: EditBookmarkViewModel
    
    init(viewModel: EditBookmarkViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = editBookmarkView
    }
    
    override func bindEvent() {
        editBookmarkView.backButton.controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: EditBookmarkViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        editBookmarkView.editTitleView.onTextChange
            .subscribe(viewModel.input.inputTitle)
            .store(in: &cancellables)
        
        editBookmarkView.editDescriptionVIew.onTextChange
            .subscribe(viewModel.input.inputDescription)
            .store(in: &cancellables)
        
        editBookmarkView.saveButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapSave)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.isEnableSaveButton
            .main
            .withUnretained(self)
            .sink { (owner: EditBookmarkViewController, isEnable: Bool) in
                owner.editBookmarkView.setEnable(isEnable)
            }
            .store(in: &cancellables)
        
        viewModel.output.title
            .main
            .withUnretained(self)
            .sink { (owner: EditBookmarkViewController, title: String) in
                owner.editBookmarkView.editTitleView.bind(title: title)
            }
            .store(in: &cancellables)
        
        viewModel.output.description
            .main
            .withUnretained(self)
            .sink { (owner: EditBookmarkViewController, description: String) in
                owner.editBookmarkView.editDescriptionVIew.bind(description: description)
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { (message: String) in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: EditBookmarkViewController, route: EditBookmarkViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: EditBookmarkViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.isLoading
            .main
            .sink { (isLoading: Bool) in
                LoadingManager.shared.showLoading(isShow: isLoading)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: EditBookmarkViewModel.Route) {
        switch route {
        case .pop:
            navigationController?.popViewController(animated: true)
        }
    }
}
