import UIKit

import DesignSystem
import Common

final class BossStoreReviewListViewController: BaseViewController {

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.contentInset.top = 20
        $0.contentInset.bottom = 80
    }

    private lazy var dataSource = BossStoreReviewListDataSource(collectionView: collectionView)

    private let viewModel: BossStoreReviewListViewModel

    init(viewModel: BossStoreReviewListViewModel = BossStoreReviewListViewModel()) {
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
            collectionView
        ])

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func bindEvent() {
        super.bindEvent()

        viewModel.output.dataSource
            .withUnretained(self)
            .sink { owner, sections in
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
                case .none: break
//                    let vc = PollDetailViewController(viewModel)
//                    owner.navigationController?.pushViewController(vc, animated: true)
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
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16

        return layout
    }
}

extension BossStoreReviewListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        viewModel.input.didSelectPollItem.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }
}

extension BossStoreReviewListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .review:
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 246)
        default:
            return .zero
        }
    }
}
