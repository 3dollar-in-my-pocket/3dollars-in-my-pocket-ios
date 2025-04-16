import UIKit

import Common
import DesignSystem
import Model

public final class FeedListViewController: BaseViewController {
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([
            FeedCell.self,
            UICollectionViewCell.self
        ])
        return collectionView
    }()
    
    private let viewModel: FeedListViewModel
    private var datasource: [FeedResponse] = []
    
    public init(viewModel: FeedListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
        viewModel.input.load.send(())
    }
    
    private func setup() {
        addNavigationBar()
        let closeImage = Icons.close.image
            .resizeImage(scaledTo: 24)
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(Colors.gray100.color)
        let buttonItem = UIBarButtonItem(
            image: closeImage,
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
        navigationItem.setAutoInsetRightBarButtonItem(buttonItem)
        
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        viewModel.output.feeds
            .main
            .withUnretained(self)
            .sink { (owner: FeedListViewController, feeds: [FeedResponse]) in
                owner.datasource = feeds
                owner.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: FeedListViewController, route: FeedListViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

// MARK: Route
extension FeedListViewController {
    private func handleRoute(_ route: FeedListViewModel.Route) {
        switch route {
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .deepLink(let deepLink):
            Environment.appModuleInterface.deepLinkHandler.handleLinkResponse(deepLink)
        }
    }
}

extension FeedListViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let feed = datasource[safe: indexPath.item] else {
            return collectionView.dequeueReusableCell(indexPath: indexPath)
        }
        let cell: FeedCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(feed: feed)
        return cell
    }
}

extension FeedListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }
}

