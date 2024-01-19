import UIKit

import DesignSystem
import Common

public final class SettingViewController: BaseViewController {
    private let settingView = SettingView()
    private let viewModel: SettingViewModel
    private var cellTypes: [SettingCellType] = []

    public init(viewModel: SettingViewModel = SettingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
    
    public override func bindViewModelInput() {
        settingView.normalAdBanner.button.controlPublisher(for: .touchUpInside)
            .map { _ in SettingAdBannerType.normal }
            .subscribe(viewModel.input.didTapAdBanner)
            .store(in: &cancellables)
        
        settingView.bossAdBanner.button.controlPublisher(for: .touchUpInside)
            .map { _ in SettingAdBannerType.boss }
            .subscribe(viewModel.input.didTapAdBanner)
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
            let viewController = EditNicknameViewController(viewModel: viewModel)
            
            navigationController?.pushViewController(viewController, animated: true)
        case .pushAgreement:
            print("💚pushAgreement")
        case .pushQna:
            print("💚pushQna")
        case .pushTeamInfo:
            print("💚pushTeamInfo")
        }
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
            let cell: SettingAccountCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
            
            cell.bind(name: name, socialType: socialType)
            cell.editNameButton.controlPublisher(for: .touchUpInside)
                .mapVoid
                .subscribe(viewModel.input.didTapEditNickname)
                .store(in: &cell.cancellables)
            return cell
            
        case .activityNotification:
            let cell: SettingMenuCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
            
            cell.bind(cellType: cellType)
            cell.switchValue
                .map { NotificationType.activity($0) }
                .subscribe(viewModel.input.toggleNotification)
                .store(in: &cell.cancellables)
            return cell
        case .marketingNotification:
            let cell: SettingMenuCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
            
            cell.bind(cellType: cellType)
            cell.switchValue
                .map { NotificationType.marketing($0) }
                .subscribe(viewModel.input.toggleNotification)
                .store(in: &cell.cancellables)
            return cell
        case .qna, .agreement, .teamInfo:
            let cell: SettingMenuCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
            
            cell.bind(cellType: cellType)
            return cell
            
        case .signout:
            let cell: SettingSignoutCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
            
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
            
        case .activityNotification, .marketingNotification, .qna, .agreement, .teamInfo:
            return SettingMenuCell.Layout.size
            
        case .signout:
            return SettingSignoutCell.Layout.size
        }
    }
}
