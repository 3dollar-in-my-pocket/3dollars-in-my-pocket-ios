import UIKit

import DesignSystem
import Common
import StoreInterface

final class StoreReviewListViewController: BaseViewController {

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.backgroundColor = .clear
        $0.delegate = self
    }
    
    private let emptyView = MyPageEmptyView().then {
        $0.isHidden = true
        $0.bind(title: "아직 작성한 리뷰가 없어요")
    }

    private lazy var dataSource = StoreReviewListDataSource(collectionView: collectionView)

    private let viewModel: StoreReviewListViewModel

    init(viewModel: StoreReviewListViewModel = StoreReviewListViewModel()) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        viewModel.input.firstLoad.send()
    }

    private func setupUI() {
        view.addSubViews([
            collectionView,
            emptyView
        ])

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    override func bindEvent() {
        super.bindEvent()

        viewModel.output.dataSource
            .withUnretained(self)
            .main
            .sink { owner, sections in
                owner.emptyView.isHidden = sections.isNotEmpty
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)

        viewModel.output.showLoading
            .removeDuplicates()
            .main
            .sink { LoadingManager.shared.showLoading(isShow: $0) }
            .store(in: &cancellables)

        viewModel.output.showToast
            .main
            .sink { ToastManager.shared.show(message: $0) }
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
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { owner, error in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(StoreReviewListCell.Layout.estimatedHeight)
            ))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(StoreReviewListCell.Layout.estimatedHeight)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 28
            section.contentInsets = .init(top: 24, leading: 20, bottom: 24, trailing: 20)
            return section
        }
        
        return layout
    }
    
    private func pushStoreDetail(storeId: Int) {
        let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)

        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushBossStoreDetail(storeId: String) {
        let viewController = Environment.storeInterface.getBossStoreDetailViewController(storeId: storeId, shouldPushReviewList: false)

        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension StoreReviewListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didSelectItem.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }
}
