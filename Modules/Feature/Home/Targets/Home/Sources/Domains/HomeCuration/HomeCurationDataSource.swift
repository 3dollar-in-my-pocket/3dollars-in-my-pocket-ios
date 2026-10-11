import UIKit

import Common
import Model

typealias HomeCurationSnapshot = NSDiffableDataSourceSnapshot<Int, HomeCurationItemIdentifier>

final class HomeCurationDataSource: UICollectionViewDiffableDataSource<Int, HomeCurationItemIdentifier> {
    private let viewModel: HomeCurationViewModel
    private var items: [HomeCurationItemIdentifier: HomeCurationSectionItem] = [:]

    init(
        collectionView: UICollectionView,
        viewModel: HomeCurationViewModel,
        rootViewController: UIViewController
    ) {
        self.viewModel = viewModel

        collectionView.register([
            HomeCurationCarouselCell.self,
            HomeListAdmobCell.self
        ])

        var itemProvider: ((HomeCurationItemIdentifier) -> HomeCurationSectionItem?)?
        super.init(collectionView: collectionView) { [weak rootViewController] collectionView, indexPath, identifier in
            switch itemProvider?(identifier) {
            case .carousel(let carousel):
                let cell: HomeCurationCarouselCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                if let rootViewController {
                    cell.bind(carousel, rootViewController: rootViewController)
                }
                let carouselId = carousel.carouselId
                cell.onTapCategory = { [weak viewModel] categoryId in
                    viewModel?.input.didTapCategory.send((carouselId: carouselId, categoryId: categoryId))
                }
                cell.onTapCard = { [weak viewModel] cardId in
                    viewModel?.input.didTapCarouselCard.send((carouselId: carouselId, cardId: cardId))
                }
                cell.onWillDisplayCard = { [weak viewModel] cardId in
                    viewModel?.input.willDisplayCarouselCard.send((carouselId: carouselId, cardId: cardId))
                }
                return cell
            case .admobCard(let card):
                let cell: HomeListAdmobCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                if let rootViewController {
                    cell.bind(card, rootViewController: rootViewController)
                }
                cell.onClickAd = { [weak viewModel] in
                    viewModel?.input.didTapAdmobItem.send(card.cardId)
                }
                return cell
            case .none:
                return UICollectionViewCell()
            }
        }
        itemProvider = { [weak self] identifier in
            self?.items[identifier]
        }

        collectionView.delegate = self
    }

    func reload(_ newItems: [HomeCurationSectionItem]) {
        let previousItems = items
        items = Dictionary(newItems.map { ($0.identifier, $0) }, uniquingKeysWith: { first, _ in first })

        let identifiers = newItems.map(\.identifier)
        var snapshot = HomeCurationSnapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(identifiers, toSection: 0)

        let changedIdentifiers = identifiers.filter { identifier in
            guard let previous = previousItems[identifier] else { return false }
            return previous != items[identifier]
        }
        snapshot.reconfigureItems(changedIdentifiers)
        apply(snapshot, animatingDifferences: false)
    }
}

extension HomeCurationDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard case .admobCard(let cardId) = itemIdentifier(for: indexPath) else { return }
        viewModel.input.willDisplayAdmobItem.send(cardId)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = UIUtils.windowBounds.width
        guard let identifier = itemIdentifier(for: indexPath) else { return .zero }

        switch items[identifier] {
        case .carousel(let carousel):
            return CGSize(width: width, height: HomeCurationCarouselCell.Layout.height(carousel))
        case .admobCard(let card):
            return CGSize(width: width, height: HomeListAdmobCell.Layout.height(card))
        case .none:
            return .zero
        }
    }
}
