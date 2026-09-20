import UIKit
import Combine

import Common
import DesignSystem

final class CommunityPollListCell: BaseCollectionViewCell {

    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 426)
        static let sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.bold.font(size: 24)
        titleLabel.textColor = Colors.gray100.color
        titleLabel.numberOfLines = 2
        return titleLabel
    }()

    private let categoryButton: UIButton = {
        let categoryButton = UIButton()
        categoryButton.titleLabel?.font = Fonts.bold.font(size: 18)
        categoryButton.setTitleColor(Colors.gray80.color, for: .normal)
        categoryButton.setImage(Icons.fireSolid.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.mainRed.color), for: .normal)
        return categoryButton
    }()

    private let arrowImageView: UIImageView = {
        let arrowImageView = UIImageView()
        arrowImageView.image = Icons.arrowRight.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray80.color)
        return arrowImageView
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    private lazy var dataSource = CommunityPollListCellDataSource(
        collectionView: collectionView,
        rootViewController: rootViewController
    )

    private var rootViewController: UIViewController?
    private var viewModel: CommunityPollListCellViewModel?

    override func setup() {
        super.setup()

        contentView.addSubViews([
            titleLabel,
            categoryButton,
            arrowImageView,
            collectionView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        categoryButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(20)
        }

        arrowImageView.snp.makeConstraints {
            $0.centerY.equalTo(categoryButton)
            $0.leading.equalTo(categoryButton.snp.trailing).offset(2)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(categoryButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = PollItemCell.Layout.size
        layout.scrollDirection = .horizontal
        layout.sectionInset = Layout.sectionInset
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16

        return layout
    }

    func bind(viewModel: CommunityPollListCellViewModel, rootViewController: UIViewController?) {
        self.viewModel = viewModel
        self.rootViewController = rootViewController

        // Input
        categoryButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didSelectCategory)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.title
            .main
            .withUnretained(self)
            .sink { owner, title in
                owner.titleLabel.text = title
            }
            .store(in: &cancellables)
        
        viewModel.output.categoryName
            .main
            .withUnretained(self)
            .sink { owner, categoryName in
                owner.categoryButton.setTitle(categoryName, for: .normal)
            }
            .store(in: &cancellables)
        
        viewModel.output.sections
            .main
            .withUnretained(self)
            .sink { owner, sections in
                owner.dataSource.reloadData(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: CommunityPollListCell, route: CommunityPollListCellViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func openUrl(with urlString: String?) {
        guard let urlString, 
                let url = URL(string: urlString), 
                UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension CommunityPollListCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didSelectPollItem.send(indexPath.item)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let offset = collectionView.getNearByItemScrollOffset(velocity: velocity, targetContentOffset: targetContentOffset, sectionInsets: Layout.sectionInset) {
            targetContentOffset.pointee = offset
        }
    }
}

// MARK: Route
extension CommunityPollListCell {
    private func handleRoute(_ route: CommunityPollListCellViewModel.Route) {
        switch route {
        case .deepLink(let advertisementResponse):
            guard let link = advertisementResponse.link else { return }
            Environment.appModuleInterface.deepLinkHandler.handleAdvertisementLink(link)
        }
    }
}
