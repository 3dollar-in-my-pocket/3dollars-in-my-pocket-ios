import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class HomeCurationCarouselCell: BaseCollectionViewCell {
    enum Layout {
        static let verticalInset: CGFloat = 20
        static let horizontalInset: CGFloat = 20
        static let titleHeight: CGFloat = 28
        static let chipVerticalInset: CGFloat = 12
        static let chipLeadingInset: CGFloat = 20
        static let chipTrailingInset: CGFloat = 22
        static let chipSpacing: CGFloat = 6
        static let chipRowHeight: CGFloat = HomeCurationCategoryChipCell.Layout.height + chipVerticalInset * 2
        static let cardSpacing: CGFloat = 8
        static let cardBottomInset: CGFloat = 12
        static let cardRowHeight: CGFloat = HomeCurationStoreCardCell.Layout.height
        static let dividerHeight: CGFloat = 1

        static func height(_ carousel: HomeCurationCarouselViewData) -> CGFloat {
            let cardsHeight = carousel.cards.isEmpty ? 0 : cardRowHeight + cardBottomInset
            return verticalInset + titleHeight + chipRowHeight + cardsHeight + verticalInset
        }
    }

    var onTapCategory: ((String) -> Void)?
    var onTapCard: ((String) -> Void)?
    var onWillDisplayCard: ((String) -> Void)?

    private weak var rootViewController: UIViewController?
    private var carousel: HomeCurationCarouselViewData?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 20)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.chipSpacing
        layout.sectionInset = UIEdgeInsets(
            top: Layout.chipVerticalInset,
            left: Layout.chipLeadingInset,
            bottom: Layout.chipVerticalInset,
            right: Layout.chipTrailingInset
        )
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([HomeCurationCategoryChipCell.self])
        return collectionView
    }()

    private lazy var cardCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.cardSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: Layout.horizontalInset, bottom: 0, right: Layout.horizontalInset)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([HomeCurationStoreCardCell.self, HomeCurationAdmobCardCell.self])
        return collectionView
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        return view
    }()

    override func setup() {
        contentView.addSubViews([titleLabel, categoryCollectionView, cardCollectionView, dividerView])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.verticalInset)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.height.equalTo(Layout.titleHeight)
        }

        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.chipRowHeight)
        }

        cardCollectionView.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.cardRowHeight)
        }

        dividerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(Layout.dividerHeight)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onTapCategory = nil
        onTapCard = nil
        onWillDisplayCard = nil
        carousel = nil
    }

    func bind(_ carousel: HomeCurationCarouselViewData, rootViewController: UIViewController) {
        let previous = self.carousel
        self.carousel = carousel
        self.rootViewController = rootViewController

        titleLabel.setSDText(carousel.header.title, customFont: Fonts.bold.font(size: 20))
        titleLabel.lineBreakMode = .byTruncatingTail

        categoryCollectionView.reloadData()
        cardCollectionView.isHidden = carousel.cards.isEmpty

        let isSameCarousel = previous?.carouselId == carousel.carouselId
        if !isSameCarousel {
            categoryCollectionView.setContentOffset(.zero, animated: false)
        }
        if !isSameCarousel || previous?.cards != carousel.cards {
            cardCollectionView.reloadData()
            cardCollectionView.setContentOffset(.zero, animated: false)
        }
    }
}

extension HomeCurationCarouselCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === categoryCollectionView {
            return carousel?.categories.count ?? 0
        }
        return carousel?.cards.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === categoryCollectionView {
            let cell: HomeCurationCategoryChipCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            if let category = carousel?.categories[safe: indexPath.item] {
                cell.bind(category)
            }
            return cell
        }

        switch carousel?.cards[safe: indexPath.item] {
        case .imagePreviewCard(let card):
            let cell: HomeCurationStoreCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(card)
            return cell
        case .admobCard(let card):
            let cell: HomeCurationAdmobCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            if let rootViewController {
                let size = HomeCurationAdmobCardCell.Layout.size(card, maxHeight: Layout.cardRowHeight)
                cell.bind(card, size: size, rootViewController: rootViewController)
            }
            cell.onClickAd = { [weak self] in
                self?.onTapCard?(card.cardId)
            }
            return cell
        case .none:
            let cell: HomeCurationStoreCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            return cell
        }
    }
}

extension HomeCurationCarouselCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === categoryCollectionView {
            guard let category = carousel?.categories[safe: indexPath.item] else { return }
            onTapCategory?(category.filter.categoryId)
            return
        }

        guard case .imagePreviewCard(let card) = carousel?.cards[safe: indexPath.item] else { return }
        onTapCard?(card.cardId)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard collectionView === cardCollectionView,
              let card = carousel?.cards[safe: indexPath.item] else { return }
        onWillDisplayCard?(card.cardId)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView === categoryCollectionView {
            guard let category = carousel?.categories[safe: indexPath.item] else { return .zero }
            return HomeCurationCategoryChipCell.Layout.size(category)
        }

        switch carousel?.cards[safe: indexPath.item] {
        case .admobCard(let card):
            let size = HomeCurationAdmobCardCell.Layout.size(card, maxHeight: Layout.cardRowHeight)
            return CGSize(width: size.width, height: Layout.cardRowHeight)
        default:
            return HomeCurationStoreCardCell.Layout.size
        }
    }
}
