import UIKit

import Common
import DesignSystem
import Log

final class EditNicknameViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let editNicknameView = EditNicknameView()
    private let viewModel: EditNicknameViewModel
    
    init(viewModel: EditNicknameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = editNicknameView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        editNicknameView.nicknameField.textField.becomeFirstResponder()
    }
    
    override func bindEvent() {
        editNicknameView.backButton.controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: EditNicknameViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        editNicknameView.nicknameField.textChanged
            .subscribe(viewModel.input.inputNickname)
            .store(in: &cancellables)
        
        editNicknameView.editButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapEdit)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.nickname
            .main
            .withUnretained(self)
            .sink { (owner: EditNicknameViewController, nickname: String) in
                owner.editNicknameView.setCurrentNickname(nickname)
            }
            .store(in: &cancellables)
        
        viewModel.output.isEnableEditButton
            .main
            .withUnretained(self)
            .sink { (owner: EditNicknameViewController, isEnable: Bool) in
                owner.editNicknameView.setEnableEditButton(isEnable)
            }
            .store(in: &cancellables)
        
        viewModel.output.isHiddenWarning
            .removeDuplicates()
            .dropFirst()
            .main
            .withUnretained(self)
            .sink { (owner: EditNicknameViewController, isHiddenWarning: Bool) in
                owner.editNicknameView.setHiddenWarning(isHiddenWarning)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: EditNicknameViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.showToast
            .main
            .sink { message in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: EditNicknameViewController, route: EditNicknameViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ rotue: EditNicknameViewModel.Route) {
        switch rotue {
        case .pop:
            navigationController?.popViewController(animated: true)
        }
    }
}
