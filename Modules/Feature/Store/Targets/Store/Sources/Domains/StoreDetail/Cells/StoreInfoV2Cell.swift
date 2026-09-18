import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreInfoV2Cell: BaseCollectionViewCell {
    enum Layout {
        static let verticalMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 20
        static let contentSpacing: CGFloat = 12
        static let cardCornerRadius: CGFloat = 20
        static let cardInset: CGFloat = 16
        static let galleryItemSize = CGSize(width: 288, height: 180)
        static let galleryItemSpacing: CGFloat = 12
        static let galleryCornerRadius: CGFloat = 12
        static let collapsedMenuItemCount = 6
        static let moreButtonHeight: CGFloat = 50
    }

    var onAction: ((StoreSectionAction) -> Void)?
    var onToggleMenuExpansion: (() -> Void)?
    var onTapGalleryImage: (([SDImage], Int) -> Void)?

    private let headerStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let subTitleLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
    private let actionButton = UIButton(type: .system)

    private lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = Layout.galleryItemSize
        layout.minimumLineSpacing = Layout.galleryItemSpacing
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.contentInset = UIEdgeInsets(
            top: 0, left: Layout.horizontalMargin, bottom: 0, right: Layout.horizontalMargin
        )
        view.register([StoreInfoGalleryImageCell.self])
        view.dataSource = self
        view.delegate = self
        return view
    }()
    private var galleryImages: [SDImage] = []

    private let cardsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.contentSpacing
        return stackView
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        cardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        galleryImages = []
        onAction = nil
        onToggleMenuExpansion = nil
        onTapGalleryImage = nil
    }

    override func setup() {
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(subTitleLabel)
        contentView.addSubViews([headerStack, actionButton, galleryCollectionView, cardsStack])
    }

    override func bindConstraints() {
        headerStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.verticalMargin)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-8)
        }
        actionButton.snp.makeConstraints {
            $0.centerY.equalTo(headerStack)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
        }
        galleryCollectionView.snp.makeConstraints {
            $0.top.equalTo(headerStack.snp.bottom).offset(Layout.contentSpacing)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.galleryItemSize.height)
        }
        cardsStack.snp.makeConstraints {
            $0.top.equalTo(galleryCollectionView.snp.bottom).offset(Layout.contentSpacing)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            $0.bottom.equalToSuperview().offset(-Layout.verticalMargin)
        }
    }

    func bind(_ section: StoreInfoV2Section, isMenuExpanded: Bool = false) {
        titleLabel.setSDText(section.header.title, lineHeight: 24)
        subTitleLabel.setSDText(section.header.subTitle, lineHeight: 18)
        subTitleLabel.isHidden = section.header.subTitle == nil
        actionButton.setOptionalSDButton(section.header.trailingAction)
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.header.trailingAction?.storeSectionAction {
            actionButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }

        bindGallery(section.imageGallery?.images ?? [])

        cardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let detailCard = section.detailCard {
            if detailCard.rows.isEmpty.isNot {
                cardsStack.addArrangedSubview(StoreInfoDetailCardView(card: detailCard) { [weak self] action in
                    self?.onAction?(action)
                })
            }
        } else {
            cardsStack.addArrangedSubview(StoreInfoDetailEmptyCardView())
        }
        section.accountCards.forEach { card in
            cardsStack.addArrangedSubview(StoreInfoAccountCardView(card: card) { [weak self] action in
                self?.onAction?(action)
            })
        }
        if let menuListCard = section.menuListCard, menuListCard.items.isEmpty.isNot {
            let menuCardView = StoreInfoMenuListCardView(card: menuListCard, isExpanded: isMenuExpanded)
            menuCardView.onTapMore = { [weak self] in self?.onToggleMenuExpansion?() }
            cardsStack.addArrangedSubview(menuCardView)
        } else {
            cardsStack.addArrangedSubview(StoreInfoMenuEmptyView())
        }
    }

    private func bindGallery(_ images: [SDImage]) {
        galleryImages = images
        let hasImages = images.isEmpty.isNot
        galleryCollectionView.isHidden = hasImages.isNot
        galleryCollectionView.snp.updateConstraints {
            $0.height.equalTo(hasImages ? Layout.galleryItemSize.height : 0)
        }
        galleryCollectionView.reloadData()
        galleryCollectionView.setContentOffset(CGPoint(x: -Layout.horizontalMargin, y: 0), animated: false)
    }
}

extension StoreInfoV2Cell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard galleryImages[safe: indexPath.item] != nil else { return }
        onTapGalleryImage?(galleryImages, indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        galleryImages.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: StoreInfoGalleryImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        if let image = galleryImages[safe: indexPath.item] {
            cell.bind(image)
        }
        return cell
    }
}

private final class StoreInfoGalleryImageCell: BaseCollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = StoreInfoV2Cell.Layout.galleryCornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.clear()
    }

    override func setup() {
        contentView.addSubview(imageView)
    }

    override func bindConstraints() {
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func bind(_ image: SDImage) {
        imageView.setImage(urlString: image.url)
    }
}

private final class StoreInfoDetailCardView: UIView {
    private enum Layout {
        static let rowSpacing: CGFloat = 8
        static let labelWidth: CGFloat = 104
        static let rowHeight: CGFloat = 18
    }

    private let onAction: (StoreSectionAction) -> Void

    init(card: DetailCard, onAction: @escaping (StoreSectionAction) -> Void) {
        self.onAction = onAction
        super.init(frame: .zero)
        layer.cornerRadius = StoreInfoV2Cell.Layout.cardCornerRadius
        setSDSurfaceStyle(card.style)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Layout.rowSpacing
        addSubViews([stack])
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(StoreInfoV2Cell.Layout.cardInset) }

        card.rows.forEach { row in
            switch row {
            case .link(let linkRow):
                stack.addArrangedSubview(makeLinkRow(linkRow))
            case .text(let textRow):
                stack.addArrangedSubview(makeTextRow(textRow))
            case .unknown:
                break
            }
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeLinkRow(_ row: DetailLinkRow) -> UIView {
        let control = UIControl()
        let label = StoreSectionTextLabel(font: Fonts.bold.font(size: 12))
        label.setSDText(row.label, lineHeight: 18)
        label.numberOfLines = 1
        let valueLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
        valueLabel.setSDText(row.value, lineHeight: 18)
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 1
        valueLabel.lineBreakMode = .byTruncatingTail

        control.addSubViews([label, valueLabel])
        control.snp.makeConstraints { $0.height.equalTo(Layout.rowHeight) }
        label.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.width.equalTo(Layout.labelWidth)
        }
        valueLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(label.snp.trailing).offset(12)
            $0.trailing.equalToSuperview()
        }
        control.addAction(UIAction { [weak self] _ in
            self?.onAction(.link(row.link, clickLog: nil))
        }, for: .touchUpInside)
        return control
    }

    private func makeTextRow(_ row: DetailTextRow) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 12))
        titleLabel.setSDText(row.title, lineHeight: 18)
        let bodyLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
        bodyLabel.setSDText(row.body, lineHeight: 18)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(bodyLabel)
        return stack
    }
}

private final class StoreInfoDetailEmptyCardView: UIView {
    private enum Layout {
        static let rowSpacing: CGFloat = 8
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = Colors.gray0.color
        layer.cornerRadius = StoreInfoV2Cell.Layout.cardCornerRadius

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Layout.rowSpacing
        addSubViews([stack])
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(StoreInfoV2Cell.Layout.cardInset) }

        [
            Strings.BossStoreDetail.Info.sns,
            Strings.BossStoreDetail.Info.introduction
        ].forEach { title in
            let label = UILabel()
            label.font = Fonts.bold.font(size: 12)
            label.textColor = Colors.gray60.color
            label.text = title
            stack.addArrangedSubview(label)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class StoreInfoAccountCardView: UIView {
    private enum Layout {
        static let copyButtonHeight: CGFloat = 34
        static let copyButtonCornerRadius: CGFloat = 10
        static let copyButtonHorizontalInset: CGFloat = 10
        static let dividerSize = CGSize(width: 1, height: 12)
    }

    private let card: AccountCopyCard
    private let onAction: (StoreSectionAction) -> Void

    init(card: AccountCopyCard, onAction: @escaping (StoreSectionAction) -> Void) {
        self.card = card
        self.onAction = onAction
        super.init(frame: .zero)
        layer.cornerRadius = StoreInfoV2Cell.Layout.cardCornerRadius
        setSDSurfaceStyle(card.style)

        let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 12))
        titleLabel.setSDText(card.title, lineHeight: 18)

        let accountStack = UIStackView()
        accountStack.axis = .horizontal
        accountStack.alignment = .center
        accountStack.spacing = 4
        let accountLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
        accountLabel.setSDText(card.account.text, lineHeight: 18)
        accountLabel.numberOfLines = 1
        accountStack.addArrangedSubview(accountLabel)
        if let additionalText = card.account.additionalText {
            let divider = UIView()
            divider.backgroundColor = Colors.gray30.color
            divider.snp.makeConstraints { $0.size.equalTo(Layout.dividerSize) }
            let nameLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
            nameLabel.setSDText(additionalText, lineHeight: 18)
            nameLabel.numberOfLines = 1
            accountStack.addArrangedSubview(divider)
            accountStack.addArrangedSubview(nameLabel)
        }

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 2
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(accountStack)

        let copyButton = UIButton(type: .custom)
        copyButton.setSDButton(card.copyButton)
        copyButton.layer.cornerRadius = Layout.copyButtonCornerRadius
        copyButton.clipsToBounds = true
        copyButton.contentEdgeInsets = UIEdgeInsets(
            top: 0, left: Layout.copyButtonHorizontalInset, bottom: 0, right: Layout.copyButtonHorizontalInset
        )
        copyButton.setContentHuggingPriority(.required, for: .horizontal)
        copyButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        copyButton.addAction(UIAction { [weak self] _ in self?.didTapCopy() }, for: .touchUpInside)

        addSubViews([textStack, copyButton])
        textStack.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview().inset(StoreInfoV2Cell.Layout.cardInset)
            $0.trailing.lessThanOrEqualTo(copyButton.snp.leading).offset(-12)
        }
        copyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(StoreInfoV2Cell.Layout.cardInset)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(Layout.copyButtonHeight)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func didTapCopy() {
        let account = [card.account.text?.text, card.account.additionalText?.text]
            .compactMap { $0 }
            .map { $0.htmlStripped }
            .joined(separator: " ")
        guard account.isNotEmpty else { return }
        UIPasteboard.general.string = account
        ToastManager.shared.show(message: Strings.BossStoreDetail.Info.copyToast)
        if let action = card.copyButton.storeSectionAction {
            onAction(action)
        } else if let clickLog = card.copyButton.clickLog {
            onAction(.custom(.init(actionType: .unknown), clickLog: clickLog))
        }
    }
}

private final class StoreInfoMenuListCardView: UIView {
    private enum Layout {
        static let itemSpacing: CGFloat = 16
        static let imageSize: CGFloat = 44
        static let imageTextSpacing: CGFloat = 8
        static let textSpacing: CGFloat = 2
    }

    var onTapMore: (() -> Void)?

    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(Colors.gray60.color, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        return button
    }()

    init(card: MenuListCard, isExpanded: Bool) {
        super.init(frame: .zero)
        layer.cornerRadius = StoreInfoV2Cell.Layout.cardCornerRadius
        setSDSurfaceStyle(card.style)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Layout.itemSpacing
        addSubViews([stack])

        let totalItemCount = card.items.count
        let isCollapsed = isExpanded.isNot && totalItemCount > StoreInfoV2Cell.Layout.collapsedMenuItemCount
        let shownItems = isCollapsed
            ? Array(card.items.prefix(StoreInfoV2Cell.Layout.collapsedMenuItemCount))
            : card.items
        shownItems.forEach { stack.addArrangedSubview(makeItemRow($0)) }

        guard isCollapsed else {
            stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(StoreInfoV2Cell.Layout.cardInset) }
            return
        }

        let divider = UIView()
        divider.backgroundColor = Colors.gray20.color
        moreButton.setTitle(Strings.StoreDetail.Menu.moreFormat(totalItemCount - shownItems.count), for: .normal)
        moreButton.addAction(UIAction { [weak self] _ in self?.onTapMore?() }, for: .touchUpInside)
        addSubViews([divider, moreButton])

        stack.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(StoreInfoV2Cell.Layout.cardInset)
        }
        divider.snp.makeConstraints {
            $0.top.equalTo(stack.snp.bottom).offset(StoreInfoV2Cell.Layout.cardInset)
            $0.leading.trailing.equalToSuperview().inset(StoreInfoV2Cell.Layout.cardInset)
            $0.height.equalTo(1)
        }
        moreButton.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(StoreInfoV2Cell.Layout.moreButtonHeight)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeItemRow(_ item: ImageMenuItem) -> UIView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = Layout.imageTextSpacing

        if let image = item.image {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = Layout.imageSize / 2
            imageView.clipsToBounds = true
            imageView.setImage(urlString: image.url)
            imageView.snp.makeConstraints { $0.size.equalTo(Layout.imageSize) }
            rowStack.addArrangedSubview(imageView)
        }

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = Layout.textSpacing
        let primaryLabel = StoreSectionTextLabel(font: Fonts.semiBold.font(size: 14))
        primaryLabel.setSDText(item.primaryText, lineHeight: 20)
        textStack.addArrangedSubview(primaryLabel)
        if let secondaryText = item.secondaryText {
            let secondaryLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
            secondaryLabel.setSDText(secondaryText, lineHeight: 18)
            textStack.addArrangedSubview(secondaryLabel)
        }
        rowStack.addArrangedSubview(textStack)
        return rowStack
    }
}

private final class StoreInfoMenuEmptyView: UIView {
    private enum Layout {
        static let height: CGFloat = 78
        static let cornerRadius: CGFloat = 6
        static let iconSize: CGFloat = 48
        static let horizontalInset: CGFloat = 20
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = Colors.gray0.color
        layer.cornerRadius = Layout.cornerRadius

        let emptyImageView = UIImageView()
        emptyImageView.image = Icons.empty02.image
        let titleLabel = UILabel()
        titleLabel.text = Strings.BossStoreDetail.Menu.empty
        titleLabel.textColor = Colors.gray50.color
        titleLabel.font = Fonts.medium.font(size: 12)
        titleLabel.numberOfLines = 0

        addSubViews([emptyImageView, titleLabel])
        snp.makeConstraints { $0.height.equalTo(Layout.height) }
        emptyImageView.snp.makeConstraints {
            $0.size.equalTo(Layout.iconSize)
            $0.leading.equalToSuperview().inset(Layout.horizontalInset)
            $0.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(emptyImageView.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
