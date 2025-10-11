import UIKit

import DesignSystem
import Common
import StoreInterface

final class CouponListViewController: BaseViewController {

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.delegate = self
    }
    
    private let emptyView = CouponEmptyView().then {
        $0.isHidden = false
        $0.bind(title: "아직 쿠폰이 없어요")
    }

    private lazy var dataSource = CouponListDataSource(collectionView: collectionView)

    private let viewModel: CouponListViewModel

    init(viewModel: CouponListViewModel) {
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
                owner.emptyView.isHidden = sections.flatMap { $0.items }.isNotEmpty
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
                case .presentUseCoupon(let viewModel):
                    let viewController = BossStoreCouponBottomSheetViewController(viewModel: viewModel)
                    owner.presentPanModal(viewController)
                case .bossStoreDetail(let storeId):
                    let viewController = BossStoreDetailViewController(storeId: storeId, shouldPushReviewList: false)
                    owner.navigationController?.pushViewController(viewController, animated: true)
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

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset.bottom = 32
        return layout
    }
}

extension CouponListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didSelectItem.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }
}

extension CouponListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let containerWidth = UIScreen.main.bounds.width

        switch dataSource.itemIdentifier(for: indexPath) {
        case .coupon(let viewModel):
            return CouponListCell.Layout.size(width: containerWidth, viewModel: viewModel)
        default:
            return .zero
        }
    }
}
