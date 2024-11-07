import UIKit

import DesignSystem
import Common
import Log
import MembershipInterface

public final class SettingViewController: BaseViewController {
    public override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let settingView = SettingView()
    private let viewModel: SettingViewModel
    private var cellTypes: [SettingCellType] = []

    public init(viewModel: SettingViewModel = SettingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = settingView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        settingView.collectionView.dataSource = self
        settingView.collectionView.delegate = self
        viewModel.input.viewDidLoad.send(())
    }
    
    public override func bindEvent() {
        settingView.backButton.controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: SettingViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    public override func bindViewModelOutput() {
        viewModel.output.cellTypes
            .main
            .withUnretained(self)
            .sink { (owner: SettingViewController, cellTypes: [SettingCellType]) in
                owner.cellTypes = cellTypes
                owner.settingView.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.output.showToast
            .main
            .sink { message in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: SettingViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: SettingViewController, route: SettingViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: SettingViewModel.Route) {
        switch route {
        case .pushEditNickname(let viewModel):
            pushEditNickname(viewModel: viewModel)
        case .pushAgreement:
            pushAgreement()
        case .pushQna:
            pushQna()
        case .pushTeamInfo:
            pushTeamInfo()
        case .goToSignin:
            goToSignin()
        case .marketingWarning:
            presentMarketingAlert()
        case .pushAccountInfo:
            pushAccountInfo()
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .openURL(let urlString):
            openURL(urlString)
        }
    }
    
    private func pushEditNickname(viewModel: EditNicknameViewModel) {
        let viewController = EditNicknameViewController(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushQna() {
        let viewController = QnaViewController()
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushAgreement() {
        let viewController = Environment.appModuleInterface.createWebViewController(
            title: "이용 약관",
            url: "https://massive-iguana-121.notion.site/3-37f521af4ac842ccba75a4fb590c506d"
        )
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushTeamInfo() {
        let viewController = TeamInfoViewController(nibName: nil, bundle: nil)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func goToSignin() {
        Environment.appModuleInterface.goToSignin()
    }
    
    private func showLogoutAlert() {
        AlertUtils.showWithCancel(
            viewController: self,
            title: Strings.Setting.Alert.Logout.title
        ) { [weak self] in
            self?.viewModel.input.logout.send(())
        }
    }
    
    private func showSignoutAlert() {
        AlertUtils.showWithCancel(
            viewController: self,
            title: Strings.Setting.Alert.Signout.title,
            message: Strings.Setting.Alert.Signout.message
        ) { [weak self] in
            self?.viewModel.input.signout.send(())
        }
    }
    
    private func presentMarketingAlert() {
        AlertUtils.showWithCancel(
            viewController: self,
            title: "혜택 알림 수신 거부",
            message: "알림을 받지 않으면 선물과 혜택을 드리는 이벤트 정보를 받으실 수 없어요. 그래도 거부하시겠어요?",
            okButtonTitle: "확인"
        ) { [weak self] in
            self?.viewModel.input.disableMarketingOff.send(())
        }
    }
    
    private func pushAccountInfo() {
        let config = AccountInfoViewModelConfig(shouldPush: true)
        let viewModel = Environment.membershipInterface.createAccountInfoViewModel(config: config)
        guard let viewController = Environment.membershipInterface.createAccountInfoViewController(viewModel: viewModel) else { return }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

extension SettingViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellTypes.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellType = cellTypes[safe: indexPath.item] else { return BaseCollectionViewCell() }
        
        switch cellType {
        case .account(let name, let socialType):
            let cell: SettingAccountCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            
            cell.bind(name: name, socialType: socialType)
            cell.editNameButton.controlPublisher(for: .touchUpInside)
                .mapVoid
                .subscribe(viewModel.input.didTapEditNickname)
                .store(in: &cell.cancellables)
            return cell
            
        case .activityNotification:
            let cell: SettingNotificationCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            
            cell.bind(cellType: cellType)
            cell.switchValue
                .map { NotificationType.activity($0) }
                .subscribe(viewModel.input.toggleNotification)
                .store(in: &cell.cancellables)
            return cell
        case .marketingNotification:
            let cell: SettingNotificationCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            
            cell.bind(cellType: cellType)
            cell.switchValue
                .map { NotificationType.marketing($0) }
                .subscribe(viewModel.input.toggleNotification)
                .store(in: &cell.cancellables)
            return cell
        case .accountInfo, .qna, .agreement, .teamInfo:
            let cell: SettingMenuCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            
            cell.bind(cellType: cellType)
            return cell
        case .advertisement(let bannerType):
            let cell: SettingAdBannerCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(bannerType)
            return cell
        case .signout:
            let cell: SettingSignoutCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            
            cell.logoutButton
                .controlPublisher(for: .touchUpInside)
                .sink(receiveValue: { [weak self] _ in
                    self?.showLogoutAlert()
                })
                .store(in: &cell.cancellables)
            
            cell.signoutButton
                .controlPublisher(for: .touchUpInside)
                .sink(receiveValue: { [weak self] _ in
                    self?.showSignoutAlert()
                })
                .store(in: &cancellables)
            return cell
        }
    }
}

extension SettingViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellType = cellTypes[safe: indexPath.item] else { return .zero }
        switch cellType {
        case .account:
            return SettingAccountCell.Layout.size
        case .activityNotification, .marketingNotification:
            return SettingNotificationCell.Layout.size
        case .qna, .agreement, .teamInfo, .accountInfo:
            return SettingMenuCell.Layout.size
        case .advertisement:
            return SettingAdBannerCell.Layout.size
        case .signout:
            return SettingSignoutCell.Layout.size
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellType = cellTypes[safe: indexPath.item] else { return }
        
        viewModel.input.didTapCell.send(cellType)
    }
}
