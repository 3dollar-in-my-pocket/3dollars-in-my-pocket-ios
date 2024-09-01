import UIKit

import DesignSystem
import Then
import Common
import Log

public final class BossStorePostListViewController: BaseViewController {
    private let viewModel: BossStorePostListViewModel
    
    private let backButton: UIButton = {
        let button = UIButton()
        let icon = Icons.arrowLeft.image.withTintColor(Colors.gray100.color)
        button.setImage(icon, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 24, right: 0)
        return collectionView
    }()
    
    public init(viewModel: BossStorePostListViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAttribute()
        setupUI()
        bind()
        
        viewModel.input.loadTrigger.send(())
    }
    
    private func setupAttribute() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([
            BossStorePostListCell.self,
            BaseCollectionViewCell.self
        ])
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        
        view.addSubViews([
            backButton,
            titleLabel,
            collectionView
        ])
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(16)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        backButton.tapPublisher
            .main
            .withUnretained(self)
            .sink(receiveValue: { (owner: BossStorePostListViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            })
            .store(in: &cancellables)
        
        // Output
        viewModel.output.sectionItems
            .main
            .sink { [weak self] sectionItems in
                if let storeName = sectionItems.first?.output.data.store.storeName {
                    self?.titleLabel.text = storeName
                }
                self?.collectionView.reloadData()
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
            .sink { (owner: BossStorePostListViewController, route: BossStorePostListViewModel.Route) in
                owner.handleRoute(route)
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
}

extension BossStorePostListViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.sectionItems.value.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellViewModel = viewModel.output.sectionItems.value[safe: indexPath.item] else { return UICollectionViewCell() }
        
        let cell: BossStorePostListCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        cell.bind(cellViewModel)
        return cell
    }
}

extension BossStorePostListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? Displayable)?.didEndDisplaying()
    }
}

extension BossStorePostListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellViewModel = viewModel.output.sectionItems.value[safe: indexPath.item] else { return .zero }
        
        return CGSize(width: collectionView.frame.width, height: BossStorePostListCell.Layout.height(viewModel: cellViewModel, width: collectionView.frame.width))
    }
}

// MARK: Route
extension BossStorePostListViewController {
    private func handleRoute(_ route: BossStorePostListViewModel.Route) {
        switch route {
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .presentPhotoDetail(let viewModel):
            presentPhotoDetail(viewModel)
        }
    }
    
    private func presentPhotoDetail(_ viewModel: BossStorePhotoViewModel) {
        let viewController = BossStorePhotoViewController(viewModel: viewModel)
        
        present(viewController, animated: true)
    }
}
