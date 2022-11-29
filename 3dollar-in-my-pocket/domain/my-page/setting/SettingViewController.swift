import UIKit

import ReactorKit
import RxSwift

final class SettingViewController: BaseViewController, View, SettingCoordinator {
    private let settingView = SettingView()
    private let settingReactor = SettingReactor(
        userDefaults: UserDefaultsUtil(),
        userService: UserService(),
        deviceService: DeviceService(),
        analyticsManager: GA.shared,
        kakaoSigninManager: KakaoSigninManager(),
        appleSigninManager: AppleSigninManager()
    )
    private weak var cooridnator: SettingCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
  
    static func instance() -> SettingViewController {
        return SettingViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.settingView
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.settingReactor
        self.cooridnator = self
        self.settingReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.settingView.backButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.cooridnator?.presenter.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.settingView.tableView.rx.itemSelected
            .filter { $0.row == 1 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.cooridnator?.pushQuestion()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.settingView.tableView.rx.itemSelected
            .filter { $0.row == 2 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.cooridnator?.pushPolicyPage()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.settingView.tableView.rx.itemSelected
            .filter { $0.row == 3 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.cooridnator?.pushPrivacy()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.settingView.tableView.rx.itemSelected
            .filter { $0.row == 5 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.cooridnator?.showSignoutAlert()
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: SettingReactor) {
        // Bind Action
        self.settingView.editNicknameButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapEditNickname }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.user }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: User())
            .drive(self.settingView.rx.user)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { SettingTableViewCellType.toCellType(user: $0.user) }
            .asDriver(onErrorJustReturn: [])
            .drive(self.settingView.tableView.rx.items) { tableView, index, cellType -> UITableViewCell in
                switch cellType {
                case .push, .question, .policy, .privacy:
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: SettingMenuTableViewCell.registerId,
                        for: IndexPath(row: index, section: 0)
                    ) as? SettingMenuTableViewCell else {
                        return BaseTableViewCell()
                    }
                    
                    cell.bind(cellType: cellType)
                    
                    if case .push = cellType {
                        cell.switchButton.rx.controlEvent(.valueChanged)
                            .withLatestFrom(cell.switchButton.rx.value)
                            .map { Reactor.Action.togglePushEnable($0) }
                            .bind(to: reactor.action)
                            .disposed(by: cell.disposeBag)
                    }
                    
                    return cell
                    
                case .account(let user):
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: SettingAccountTableViewCell.registerId,
                        for: IndexPath(row: index, section: 0)
                    ) as? SettingAccountTableViewCell else {
                        return BaseTableViewCell()
                    }
                    
                    cell.bind(socialType: user.socialType)
                    cell.logoutButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .asDriver(onErrorJustReturn: ())
                        .drive(onNext: { [weak self] _ in
                            self?.cooridnator?.showLogoutAlert()
                        })
                        .disposed(by: cell.disposeBag)
                    return cell
                    
                case .signout:
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: SettingSignoutTableViewCell.registerId,
                        for: IndexPath(row: index, section: 0)
                    ) as? SettingSignoutTableViewCell else {
                        return BaseTableViewCell()
                    }
                    
                    return cell
                }
            }
            .disposed(by: self.disposeBag)
        
        
        // Bind Pulse
        reactor.pulse(\.$pushEditNickname)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] nickname in
                self?.cooridnator?.pushEditNickname(nickname: nickname)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$goToSignin)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.cooridnator?.goToSignin()
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$showLoading)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.cooridnator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$showErrorAlert)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.cooridnator?.showErrorAlert(error: error)
            })
            .disposed(by: self.disposeBag)
    }
}
