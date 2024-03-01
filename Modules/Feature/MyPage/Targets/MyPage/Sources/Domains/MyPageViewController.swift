import UIKit

import Then
import SnapKit

import Model
import DesignSystem
import Common

public final class MyPageViewController: BaseViewController {
    
    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private let refreshControl = UIRefreshControl().then {
        $0.tintColor = .white
    }
    
    private let navigationBackgroundView = UIView().then {
        $0.backgroundColor = Colors.gray100.color
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = Colors.systemWhite.color
        $0.font = Fonts.medium.font(size: 16)
        $0.text = "마이 페이지"
    }
    
    private let settingButton = UIButton().then {
        $0.setImage(Icons.setting.image.withTintColor(Colors.mainPink.color), for: .normal)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = Colors.gray100.color
        $0.contentInset = .init(top: 0, left: 0, bottom: 24, right: 0)
        $0.refreshControl = self.refreshControl
        $0.delegate = self
    }
    
    private lazy var dataSource = MyPageDataSource(collectionView: collectionView)
    
    private let viewModel: MyPageViewModel
    
    init(viewModel: MyPageViewModel = MyPageViewModel()) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func instance() -> UINavigationController {
        let viewController = MyPageViewController()
        viewController.tabBarItem = UITabBarItem(
            title: nil,
            image: Icons.mySolid.image.resizeImage(scaledTo: 30),
            tag: TabBarTag.my.rawValue
        )

        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.loadTrigger.send(())
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.gray100.color
        
        view.addSubViews([
            navigationBackgroundView,
            collectionView
        ])
        
        navigationBackgroundView.addSubViews([
            titleLabel,
            settingButton
        ])
        
        navigationBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        settingButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(self.navigationBackgroundView.snp.bottom)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }

    public override func bindEvent() {
        super.bindEvent()
        
        settingButton.controlPublisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: MyPageViewController, _) in
                owner.pushSetting()
            }
            .store(in: &cancellables)
    }
    
    override public func bindViewModelInput() {
        super.bindViewModelInput()
        
        refreshControl.controlPublisher(for: .valueChanged)
            .mapVoid
            .subscribe(viewModel.input.reloadTrigger)
            .store(in: &cancellables)
    }
    
    public override func bindViewModelOutput() {
        super.bindViewModelOutput()
        
        viewModel.output.sections
            .main
            .withUnretained(self)
            .sink { owner, sections in
                if owner.refreshControl.isRefreshing {
                    owner.refreshControl.endRefreshing()
                }
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                let vc = switch route {
                case .registeredStoreList: RegisteredStoreListViewController()
                case .review(let viewModel): ReviewTabViewController(viewModel: viewModel)
                case .visitStore(let viewModel): VisitStoreListViewController(viewModel: viewModel)
                case .medal(let viewModel): MyMedalViewController(viewModel: viewModel)
                case .storeDetail(let storeId): Environment.storeInterface.getStoreDetailViewController(storeId: storeId)
                case .bossStoreDetail(let storeId): Environment.storeInterface.getBossStoreDetailViewController(storeId: storeId)
                case .favoriteStore: BookmarkListViewController()
                case .pollDetail(let pollId): Environment.communityInterface.getPollDetailViewController(pollId: pollId)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }
    
    private func pushSetting() {
        let viewController = SettingViewController()
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MyPageViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            viewModel.input.didSelect.send(item)
        }
    }
}

extension MyPageViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .overview:
            return CGSize(width: collectionView.frame.width, height: MyPageOverviewCell.Layout.height) 
        case .visitStore(let viewModel):
            return CGSize(width: collectionView.frame.width, height: MyPageStoreListCell.Layout.height(viewModel.output.items)) 
        case .favoriteStore(let viewModel):
            return CGSize(width: collectionView.frame.width, height: MyPageStoreListCell.Layout.height(viewModel.output.items))
        case .empty:
            return CGSize(width: collectionView.frame.width, height: MyPageEmptyCell.Layout.height)
        case .pollTotalParticipantsCount:
            return CGSize(width: collectionView.frame.width, height: MyPagePollTotalParticipantsCountCell.Layout.height)
        case .poll:
            return CGSize(width: collectionView.frame.width, height: MyPagePollItemCell.Layout.height)
        case .none:
            return .zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch dataSource.sectionIdentifier(section: section)?.type {
        case .visitStore, .favoriteStore, .poll:
            return CGSize(width: collectionView.frame.width, height: MyPageSectionHeaderView.Layout.height)  
        default:
            return .zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch dataSource.sectionIdentifier(section: section)?.type {
        case .overview:
            return UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 36, right: 0)
        }
    }
}
