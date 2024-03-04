import UIKit

import Then
import SnapKit

import Model
import DesignSystem
import Common
import StoreInterface

/// 방문 인증 내역
public final class VisitStoreListViewController: BaseViewController {
    
    private let navigationBar = MyPageNavigationBar(title: "방문 인증 내역")
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = Colors.gray100.color
        $0.contentInset = .init(top: 0, left: 20, bottom: 24, right: 20)
        $0.delegate = self
    }
    
    private let emptyView = MyPageEmptyView().then {
        $0.isHidden = true
        $0.bind(title: "방문 인증 내역이 없어요!", description: "방문하고 가게 정확도를 높혀봐요")
    }
    
    private lazy var dataSource = VisitStoreListDataSource(collectionView: collectionView)
    
    private let viewModel: VisitStoreListViewModel
    
    init(viewModel: VisitStoreListViewModel = VisitStoreListViewModel()) {
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
            navigationBar,
            collectionView,
            emptyView
        ])
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(MyPageNavigationBar.Layout.height)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(self.navigationBar.snp.bottom)
            $0.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    public override func bindEvent() {
        super.bindEvent()
        
        navigationBar.backButton
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
        
        viewModel.output.sections
            .main
            .withUnretained(self)
            .sink { owner, sections in
                owner.emptyView.isHidden = sections.isNotEmpty
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .storeDetail(let storeId):
                    owner.pushStoreDetail(storeId: storeId)
                case .bossStoreDetail(let storeId):
                    owner.pushBossStoreDetail(storeId: storeId)
                }
            }
            .store(in: &cancellables)
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = .init(top: 0, left: 0, bottom: 40, right: 0)
        return layout
    }
    
    private func pushStoreDetail(storeId: Int) {
        let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)

        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushBossStoreDetail(storeId: String) {
        let viewController = Environment.storeInterface.getBossStoreDetailViewController(storeId: storeId)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension VisitStoreListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didSelectItem.send(indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplaytCell.send(indexPath.section)
    }
}

extension VisitStoreListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: VisitStoreItemCell.Layout.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: VisitStoreHeaderView.Layout.height)
    }
}
