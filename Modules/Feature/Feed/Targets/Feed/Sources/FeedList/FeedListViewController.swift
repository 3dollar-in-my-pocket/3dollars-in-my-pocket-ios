import UIKit

import Common
import DesignSystem
import Model
import CombineCocoa

public final class FeedListViewController: BaseViewController {
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([
            FeedCell.self,
            UICollectionViewCell.self
        ])
        collectionView.backgroundColor = Colors.gray0.color
        collectionView.contentInset = .init(top: 20, left: 16, bottom: 20, right: 16)
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    private let emptyListView = EmptyListView()

    private let refreshControl = UIRefreshControl()
    private let viewModel: FeedListViewModel
    private var datasource: [FeedResponse] = []
    private var isRefreshing = false
    
    public init(viewModel: FeedListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
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
        view.backgroundColor = Colors.systemWhite.color
        setupNavigation()
        view.addSubViews([
            collectionView,
            emptyListView
        ])
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            if let navigationBar {
                $0.top.equalTo(navigationBar.snp.bottom)
            } else {
                $0.top.equalTo(view.safeAreaLayoutGuide)
            }
        }
        
        emptyListView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-40)
        }
    }
    
    private func setupNavigation() {
        addNavigationBar()
        navigationBar?.standardAppearance.titleTextAttributes = [
            .foregroundColor: Colors.gray100.color,
            .font: DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        ]
        navigationBar?.tintColor = Colors.gray100.color
        navigationItem.title = Strings.FeedList.Empty.title
        let closeImage = Icons.close.image
            .resizeImage(scaledTo: 24)
        let buttonItem = UIBarButtonItem(
            image: closeImage,
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
        navigationItem.setAutoInsetRightBarButtonItem(buttonItem)
    }
    
    private func bind() {
        refreshControl.isRefreshingPublisher
            .filter { $0 }
            .withUnretained(self)
            .sink { (owner: FeedListViewController, _) in
                owner.isRefreshing = true
            }
            .store(in: &cancellables)
        
        viewModel.output.feeds
            .main
            .withUnretained(self)
            .sink { (owner: FeedListViewController, feeds: [FeedResponse]) in
                owner.datasource = feeds
                owner.collectionView.reloadData()
                owner.setEmptyListView(feeds: feeds)
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
    
    private func setEmptyListView(feeds: [FeedResponse]) {
        emptyListView.isHidden = feeds.isNotEmpty
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

extension FeedListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let feed = datasource[safe: indexPath.item] else { return .zero }
        let width = UIUtils.windowBounds.width - 32
        let height = FeedCell.Layout.calculateHeight(feed: feed)
        
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isRefreshing {
            viewModel.input.reload.send(())
            isRefreshing = false
            refreshControl.endRefreshing()
        }
    }
}

extension FeedListViewController {
    private class EmptyListView: UIStackView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setupUI()
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            axis = .vertical
            alignment = .center
            
            let emptyImageView = UIImageView(image: FeedAsset.imgEmptyList.image)
            emptyImageView.contentMode = .scaleAspectFit
            addArrangedSubview(emptyImageView)
            setCustomSpacing(8, after: emptyImageView)
            
            let titleLabel = UILabel()
            titleLabel.text = Strings.FeedList.Empty.title
            titleLabel.font = Fonts.bold.font(size: 16)
            titleLabel.textColor = Colors.gray70.color
            addArrangedSubview(titleLabel)
            setCustomSpacing(4, after: titleLabel)
            
            let descriptionLabel = UILabel()
            descriptionLabel.text = Strings.FeedList.Empty.description
            descriptionLabel.font = Fonts.medium.font(size: 12)
            descriptionLabel.textColor = Colors.gray70.color
            addArrangedSubview(descriptionLabel)
        }
    }
}
