import UIKit

import Common
import DesignSystem
import Model
import CombineCocoa

public final class FeedListViewController: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.gray100.color
        label.text = Strings.FeedList.title
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        let image = Icons.close.image
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(Colors.gray100.color)
            .resizeImage(scaledTo: 24)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = Colors.gray0.color
        collectionView.contentInset = .init(top: 20, left: 16, bottom: 20, right: 16)
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    private let emptyListView = EmptyListView()

    private let refreshControl = UIRefreshControl()
    private let viewModel: FeedListViewModel
    private lazy var datasource = FeedListDatasource(collectionView: collectionView, rootViewController: self)
    private var isRefreshing = false
    
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
        setupCollectionView()
        bind()
        viewModel.input.load.send(())
    }
    
    private func setup() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubViews([
            titleLabel,
            closeButton,
            collectionView,
            emptyListView
        ])
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(closeButton)
        }
        
        closeButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(closeButton.snp.bottom).offset(16)
        }
        
        emptyListView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-40)
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = datasource
        collectionView.delegate = self
    }
    
    private func bind() {
        closeButton.tapPublisher
            .withUnretained(self)
            .sink { (owner: FeedListViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        refreshControl.isRefreshingPublisher
            .filter { $0 }
            .withUnretained(self)
            .sink { (owner: FeedListViewController, _) in
                owner.isRefreshing = true
            }
            .store(in: &cancellables)
        
        viewModel.output.datasource
            .main
            .sink { [weak self] sections in
                self?.datasource.reload(sections)
                self?.setEmptyListViewHidden(isHidden: sections.first?.items.count != 1)
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
    
    private func setEmptyListViewHidden(isHidden: Bool) {
        emptyListView.isHidden = isHidden
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

extension FeedListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIUtils.windowBounds.width - 32
        
        switch datasource.itemIdentifier(for: indexPath) {
        case .feed(let feed):
            let height = FeedCell.Layout.calculateHeight(feed: feed)
            
            return CGSize(width: width, height: height)
        case .advertisement:
            return CGSize(width: width, height: FeedAdvertisementCell.Layout.height)
        case .none:
            return .zero
        }
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
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didTapFeed.send(indexPath.item)
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
