import UIKit

import ReactorKit

final class EditNicknameViewController: BaseViewController, View, EditNicknameCoordinator {
    private let editNicknameView = EditNicknameView()
    private let editNicknameReactor = EditNicknameReactor(
        userService: UserService(),
        globalState: GlobalState.shared
    )
    private weak var coordinator: EditNicknameCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
  
    static func instance(currentName: String) -> EditNicknameViewController {
        return EditNicknameViewController(currentName: currentName).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    init(currentName: String) {
        super.init(nibName: nil, bundle: nil)
        self.editNicknameView.bind(nickname: currentName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.editNicknameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.editNicknameReactor
        self.coordinator = self
    }
  
    override func bindEvent() {
        self.editNicknameView.backButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.presenter.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editNicknameView.tapGestureView.rx.event
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.editNicknameView.endEditing(true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editNicknameReactor.showLoadingPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editNicknameReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: EditNicknameReactor) {
        // Bind Action
        self.editNicknameView.nicknameField.rx.text.orEmpty
            .map { Reactor.Action.inputNickname($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.editNicknameView.editImageButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapEditNickname }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.editNicknameView.editLabelButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapEditNickname }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.isEnableEditButton }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(self.editNicknameView.rx.isEnableEditButton)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isHiddenWarning }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
            .drive(self.editNicknameView.rx.isHiddenWarning)
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pop)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.presenter.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
    }
}
