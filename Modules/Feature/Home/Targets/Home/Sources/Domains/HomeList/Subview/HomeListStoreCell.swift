import UIKit

import Common
import DesignSystem
import Model

import Kingfisher
import SnapKit

final class HomeListStoreCell: BaseCollectionViewCell {
    var onTapImage: (([SDImage], Int) -> Void)?
    var onTapBody: (() -> Void)?

    enum Layout {
        static let defaultImageSize = CGSize(width: 120, height: 120)
        static let imageSpacing: CGFloat = 4
        static let bodySpacing: CGFloat = 4
        static let multipleBodyWidth: CGFloat = 300
        static let bodyTrailingInset: CGFloat = 20
        static let bodyLabelInset: CGFloat = 12
        static var imageAvailableWidth: CGFloat {
            return UIUtils.windowBounds.width - 40
        }

        static func imageRowHeight(images: [SDImage]) -> CGFloat {
            return PreviewImageLayout.rowHeight(images: images, defaultHeight: defaultImageSize.height)
        }

        static func imageSize(images: [SDImage], at index: Int) -> CGSize {
            return PreviewImageLayout.itemSize(
                style: images[safe: index]?.style,
                count: images.count,
                availableWidth: imageAvailableWidth,
                spacing: imageSpacing,
                defaultSize: defaultImageSize
            )
        }

        static func height(response: HomeListBasicCardResponse) -> CGFloat {
            var height: CGFloat = 16 // top padding

            let hasHeader = response.header.title != nil || response.header.badge != nil
            if hasHeader {
                height += 24
            }

            let hasPrimary = response.metadata.primary.isNotEmpty
            if hasPrimary {
                if hasHeader { height += 4 }
                height += 20
            }

            let hasSecondary = response.metadata.secondary.isNotEmpty
            if hasSecondary {
                if hasHeader || hasPrimary { height += 4 }
                height += 20
            }

            if response.images.isNotEmpty {
                if hasHeader || hasPrimary || hasSecondary { height += 8 }
                height += imageRowHeight(images: response.images)
            }

            let bodies = visibleBodies(response.bodies)
            if bodies.isNotEmpty {
                if hasHeader || hasPrimary || hasSecondary || response.images.isNotEmpty {
                    height += 8
                }
                height += bodiesHeight(bodies: bodies)
            }

            height += 16 // bottom padding
            return height
        }
        
        static func visibleBodies(_ bodies: [HomeListCardBody]) -> [HomeListCardBody] {
            return bodies.filter { $0.text.text.isNotEmpty }
        }

        static func bodyWidth(bodyCount: Int) -> CGFloat {
            guard bodyCount > 1 else {
                return imageAvailableWidth
            }
            return multipleBodyWidth
        }

        static func bodiesHeight(bodies: [HomeListCardBody]) -> CGFloat {
            let labelWidth = bodyWidth(bodyCount: bodies.count) - bodyLabelInset * 2
            return bodies.map { bodyHeight(body: $0, labelWidth: labelWidth) }.max() ?? 0
        }

        static func bodyHeight(body: HomeListCardBody, labelWidth: CGFloat) -> CGFloat {
            let font = Fonts.medium.font(size: 12)
            let lineHeight: CGFloat = 18
            let maxLines: CGFloat = 2
            let maxHeight = ceil(lineHeight * maxLines)

            let textHeight: CGFloat
            if body.text.isHtml {
                let label = UILabel()
                label.setSDText(body.text, customFont: font, lineHeight: lineHeight)
                textHeight = label.attributedText?.height(width: labelWidth) ?? 0
            } else {
                textHeight = body.text.text.height(font: font, width: labelWidth, lineHeight: lineHeight)
            }

            return min(ceil(textHeight), maxHeight) + 22
        }
    }

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.layoutMargins = .init(top: 16, left: 20, bottom: 15, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 4
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private let primaryMetadataStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    private let secondaryMetadataStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    private lazy var imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.imageSpacing
        layout.minimumInteritemSpacing = Layout.imageSpacing
        layout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([HomeListStoreImageCell.self])
        return collectionView
    }()

    private var images: [SDImage] = []
    private var imagesHeightConstraint: Constraint?

    private let bodiesScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
    }()

    private let bodiesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = Layout.bodySpacing
        return stackView
    }()

    private var bodiesHeightConstraint: Constraint?
    
    private let bottomBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        return view
    }()

    override func setup() {
        contentView.addSubview(contentStackView)
        contentView.addSubview(bottomBorderView)

        contentStackView.addArrangedSubview(headerStackView)
        contentStackView.addArrangedSubview(primaryMetadataStackView, previousSpace: 4)
        contentStackView.addArrangedSubview(secondaryMetadataStackView, previousSpace: 4)
        contentStackView.addArrangedSubview(imagesCollectionView, previousSpace: 8)
        contentStackView.addArrangedSubview(bodiesScrollView, previousSpace: 8)

        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(badgeImageView)
        headerStackView.addArrangedSubview(UIView())

        bodiesScrollView.addSubview(bodiesStackView)
        bodiesScrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBodies)))
    }

    override func bindConstraints() {
        contentStackView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(bottomBorderView.snp.top)
        }
        
        bottomBorderView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        headerStackView.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        primaryMetadataStackView.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        secondaryMetadataStackView.snp.makeConstraints { make in
            make.height.equalTo(20)
        }

        bodiesScrollView.snp.makeConstraints {
            self.bodiesHeightConstraint = $0.height.equalTo(0).constraint
        }

        bodiesStackView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Layout.bodyTrailingInset)
            $0.height.equalTo(bodiesScrollView.frameLayoutGuide)
        }

        imagesCollectionView.snp.makeConstraints {
            self.imagesHeightConstraint = $0.height.equalTo(Layout.defaultImageSize.height).constraint
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        primaryMetadataStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        secondaryMetadataStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        images = []
        bodiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        bodiesScrollView.isHidden = true
        badgeImageView.kf.cancelDownloadTask()
        badgeImageView.image = nil
        onTapImage = nil
        onTapBody = nil
    }

    func bind(_ card: HomeListBasicCardResponse) {
        contentView.setSDSurfaceStyle(card.style)
        bindHeader(card.header)
        bindPrimaryMetadata(card.metadata)
        bindSecondaryMetadata(card.metadata)
        bindImages(card.images)
        bindBodies(card.bodies)
    }

    private func bindHeader(_ header: HomeListCardHeader) {
        if let title = header.title {
            titleLabel.setSDText(title)
            titleLabel.isHidden = false
        } else {
            titleLabel.text = nil
            titleLabel.isHidden = true
        }

        if let badge = header.badge {
            badgeImageView.setSDImage(badge)
            badgeImageView.isHidden = false
        } else {
            badgeImageView.image = nil
            badgeImageView.snp.removeConstraints()
            badgeImageView.isHidden = true
        }

        headerStackView.isHidden = (titleLabel.isHidden && badgeImageView.isHidden)
    }

    private func bindPrimaryMetadata(_ metadata: HomeListCardMetadata) {
        let chips = metadata.primary
        if chips.isEmpty {
            primaryMetadataStackView.isHidden = true
            return
        }
        primaryMetadataStackView.isHidden = false

        for (index, chip) in chips.enumerated() {
            primaryMetadataStackView.addArrangedSubview(
                makeChipView(chip: chip)
            )
            if index < chips.count - 1 {
                primaryMetadataStackView.addArrangedSubview(makeSeparatorView(metadata.separator))
            }
        }
        primaryMetadataStackView.addArrangedSubview(UIView())
    }

    private func bindSecondaryMetadata(_ metadata: HomeListCardMetadata) {
        let chips = metadata.secondary
        if chips.isEmpty {
            secondaryMetadataStackView.isHidden = true
            return
        }
        secondaryMetadataStackView.isHidden = false

        for (index, chip) in chips.enumerated() {
            secondaryMetadataStackView.addArrangedSubview(
                makeChipView(chip: chip)
            )
            if index < chips.count - 1 {
                secondaryMetadataStackView.addArrangedSubview(makeSeparatorView(metadata.separator))
            }
        }
        secondaryMetadataStackView.addArrangedSubview(UIView())
    }

    private func makeChipView(chip: SDChip) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 2

        if let image = chip.image {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.setSDImage(image)
            stack.addArrangedSubview(imageView)
        }

        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray60.color
        label.setSDText(chip.text)
        if let style = chip.style {
            label.setSDChipStyle(style)
        }
        stack.addArrangedSubview(label)
        return stack
    }

    private func makeSeparatorView(_ image: SDImage) -> UIView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setSDImage(image)
        return imageView
    }

    private func bindImages(_ images: [SDImage]) {
        if images.isEmpty {
            self.images = []
            imagesCollectionView.isHidden = true
            return
        }
        imagesCollectionView.isHidden = false
        self.images = images
        imagesHeightConstraint?.update(offset: Layout.imageRowHeight(images: images))
        imagesCollectionView.isScrollEnabled = images.count > PreviewImageLayout.fillMaxCount
        imagesCollectionView.collectionViewLayout.invalidateLayout()
        imagesCollectionView.reloadData()
    }

    private func bindBodies(_ bodies: [HomeListCardBody]) {
        bodiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let visibleBodies = Layout.visibleBodies(bodies)
        guard visibleBodies.isNotEmpty else {
            bodiesScrollView.isHidden = true
            return
        }
        bodiesScrollView.isHidden = false
        bodiesHeightConstraint?.update(offset: Layout.bodiesHeight(bodies: visibleBodies))

        let bodyWidth = Layout.bodyWidth(bodyCount: visibleBodies.count)
        for body in visibleBodies {
            let bodyView = makeBodyView(body: body)
            bodyView.snp.makeConstraints {
                $0.width.equalTo(bodyWidth)
            }
            bodiesStackView.addArrangedSubview(bodyView)
        }
        bodiesScrollView.setContentOffset(.zero, animated: false)
    }

    @objc private func didTapBodies() {
        onTapBody?()
    }

    private func makeBodyView(body: HomeListCardBody) -> UIView {
        let containerView = UIView()
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.setSDSurfaceStyle(body.style)

        let label = UILabel()
        label.font = Fonts.medium.font(size: 13)
        label.textColor = Colors.gray70.color
        label.numberOfLines = 2
        label.setSDText(body.text)

        containerView.addSubview(label)
        label.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(Layout.bodyLabelInset)
            $0.bottom.lessThanOrEqualToSuperview().inset(Layout.bodyLabelInset)
        }
        return containerView
    }
}

extension HomeListStoreCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: HomeListStoreImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        if let image = self.images[safe: indexPath.item] {
            cell.bind(image)
        }

        return cell
    }
}

extension HomeListStoreCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTapImage?(images, indexPath.item)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return Layout.imageSize(images: images, at: indexPath.item)
    }
}
