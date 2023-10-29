import UIKit

import DesignSystem
import Then
import Common

final class BossStoreDetailViewController: BaseViewController {
    
    private let backButton = UIButton().then {
        $0.setImage(
            Icons.arrowLeft.image.withTintColor(Colors.gray100.color),
            for: .normal
        )
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.delegate = self
    }

    private lazy var dataSource = BossStoreDetailDataSource(collectionView: collectionView, containerVC: self)

    private let bottomStickyView = BottomStickyView()

    private let viewModel: BossStoreDetailViewModel

    public static func instance(storeId: String) -> BossStoreDetailViewController {
        return BossStoreDetailViewController(storeId: storeId)
    }

    public init(storeId: String) {
        self.viewModel = BossStoreDetailViewModel(storeId: storeId)

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
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
        view.backgroundColor = Colors.systemWhite.color

        view.addSubViews([
            backButton,
            collectionView,
            bottomStickyView
        ])

        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }

        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(16)
            $0.right.equalToSuperview()
            $0.bottom.equalTo(bottomStickyView.snp.top)
        }

        bottomStickyView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(BottomStickyView.Layout.height)
        }

        bottomStickyView.visitButton.setTitle("리뷰 남기기", for: .normal)
    }

    override func bindEvent() {
        super.bindEvent()

        // Input
        backButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)

        bottomStickyView.saveButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapSave)
            .store(in: &cancellables)

        bottomStickyView.visitButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapReviewWriteButton)
            .store(in: &cancellables)

        // Output
        viewModel.output.showLoading
            .removeDuplicates()
            .main
            .sink { LoadingManager.shared.showLoading(isShow: $0) }
            .store(in: &cancellables)

        viewModel.output.toast
            .main
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)

        viewModel.output.dataSource
            .main
            .withUnretained(self)
            .sink { owner, sections in
                owner.dataSource.reloadData(sections)
            }
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .openUrl(let url):
                    UIApplication.shared.open(url)
                case .presentMapDetail(let viewModel):
                    owner.presentMapDetail(viewModel)
                case .presentNavigation:
                    owner.presentNavigationModal()
                }
            }
            .store(in: &cancellables)

            viewModel.output.isFavorited
                .main
                .withUnretained(self)
                .sink { owner, isSaved in
                    owner.bottomStickyView.setSaved(isSaved)
                }
                .store(in: &cancellables)
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }

    private func presentNavigationModal() {
        let alertController = UIAlertController(
            title: Strings.NavigationBottomSheet.title,
            message: Strings.NavigationBottomSheet.message,
            preferredStyle: .actionSheet
        )
        let naverAction = UIAlertAction(
            title: Strings.NavigationBottomSheet.Action.naverMap,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.input.didTapNavigationAction.send(.naver)
        }
        let kakaoAction = UIAlertAction(
            title: Strings.NavigationBottomSheet.Action.kakaoMap,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.input.didTapNavigationAction.send(.kakao)
        }
        let cancelAction = UIAlertAction(title: Strings.NavigationBottomSheet.Action.cancel, style: .cancel)

        alertController.addAction(naverAction)
        alertController.addAction(kakaoAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func presentMapDetail(_ viewModel: MapDetailViewModel) {
        let viewController = MapDetailViewController(viewModel: viewModel)

        present(viewController, animated: true)
    }
}

extension BossStoreDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 40

        switch dataSource.itemIdentifier(for: indexPath) {
        case .overview:
            return CGSize(width: width, height: StoreDetailOverviewCell.Layout.height)
        case .workday:
            return CGSize(width: width, height: BossStoreWorkdayCell.Layout.height)
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = UIScreen.main.bounds.width

        switch dataSource.sectionIdentifier(section: section)?.type {
        default:
            return .zero
        }
    }
}

extension BossStoreDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch dataSource.itemIdentifier(for: indexPath) {
        default:
            break
        }
    }
}
