import UIKit

import Then
import SnapKit

import Model
import DesignSystem
import Common
import StoreInterface
import Log

/// 제보한 가게
public final class RegisteredStoreListViewController: BaseViewController {
    public override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private let myPageNavigationBar = MyPageNavigationBar(title: "제보한 가게")
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = Colors.gray100.color
        $0.contentInset = .init(top: 0, left: 0, bottom: 24, right: 0)
        $0.dataSource = self
        $0.delegate = self
        $0.registerSectionHeader([RegisteredStoreHeaderView.self])
        $0.register([RegisteredStoreItemCell.self])
    }
    
    private let emptyView = MyPageEmptyView().then {
        $0.isHidden = true
        $0.bind(title: "제보한 가게가 없어요!", description: "발견한 가게를 제보해 보세요 :)")
    }
    
    private let viewModel: RegisteredStoreListViewModel
    
    init(viewModel: RegisteredStoreListViewModel = RegisteredStoreListViewModel()) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            myPageNavigationBar,
            collectionView,
            emptyView
        ])
        
        myPageNavigationBar.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(MyPageNavigationBar.Layout.height)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(self.myPageNavigationBar.snp.bottom)
            $0.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    public override func bindEvent() {
        super.bindEvent()
        
        myPageNavigationBar.backButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override public func bindViewModelInput() {
        super.bindViewModelInput()
    }
    
    public override func bindViewModelOutput() {
        super.bindViewModelOutput()
        
        viewModel.output.showLoading
            .removeDuplicates()
            .main
            .sink { LoadingManager.shared.showLoading(isShow: $0) }
            .store(in: &cancellables)

        viewModel.output.showToast
            .main
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { owner, error in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.sectionItems
            .main
            .withUnretained(self)
            .sink { owner, sectionItems in
                owner.emptyView.isHidden = sectionItems.isNotEmpty
                owner.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .storeDetail(let storeId):
                    owner.pushStoreDetail(storeId: storeId)
                }
            }
            .store(in: &cancellables)
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        return layout
    }
    
    private func pushStoreDetail(storeId: Int) {
        let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)

        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension RegisteredStoreListViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.sectionItems.value.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewModel.output.sectionItems.value[safe: indexPath.item] else { return UICollectionViewCell() }
        
        let cell: RegisteredStoreItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(item: item)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView: RegisteredStoreHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
        headerView.bind(count: viewModel.output.totalCount.value)
        return headerView
    }
}

extension RegisteredStoreListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didSelectItem.send(indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }
}

extension RegisteredStoreListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: RegisteredStoreItemCell.Layout.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard viewModel.output.totalCount.value > 0 else {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width, height: RegisteredStoreHeaderView.Layout.height)
    }
}
