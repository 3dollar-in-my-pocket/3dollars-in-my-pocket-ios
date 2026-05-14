import UIKit

import Common
import DesignSystem
import Model

import Kingfisher

final class HomeListStoreCell: BaseCollectionViewCell {
    enum Layout {
        static let horizontalInset: CGFloat = 20
        static let imageRowHeight: CGFloat = 120
        static let imageSpacing: CGFloat = 4
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
                height += imageRowHeight
            }

            if let body = response.bodies.first, body.text.text.isNotEmpty {
                if hasHeader || hasPrimary || hasSecondary || response.images.isNotEmpty {
                    height += 8
                }
                height += bodyHeight(body: body)
            }

            height += 16 // bottom padding
            return height
        }
        
        static func bodyHeight(body: HomeListCardBody) -> CGFloat {
            let font = Fonts.medium.font(size: 12)
            let lineHeight: CGFloat = 18
            let maxLines: CGFloat = 2
            let bodyLabelWidth = UIUtils.windowBounds.width - 64
            let maxHeight = ceil(lineHeight * maxLines)

            let textHeight: CGFloat
            if body.text.isHtml {
                let label = UILabel()
                label.setSDText(body.text, customFont: font, lineHeight: lineHeight)
                textHeight = label.attributedText?.height(width: bodyLabelWidth) ?? 0
            } else {
                textHeight = body.text.text.height(font: font, width: bodyLabelWidth, lineHeight: lineHeight)
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

    private let bodyHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()

    private let bodyContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 13)
        label.textColor = Colors.gray70.color
        label.numberOfLines = 2
        return label
    }()
    
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
        contentStackView.addArrangedSubview(bodyHorizontalStackView, previousSpace: 8)

        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(badgeImageView)

        let bodyRightPaddingView = UIView()
        bodyRightPaddingView.snp.makeConstraints {
            $0.width.equalTo(20)
        }
        
        bodyHorizontalStackView.addArrangedSubview(bodyContainerView)
        bodyHorizontalStackView.addArrangedSubview(bodyRightPaddingView)

        bodyContainerView.addSubview(bodyLabel)
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

        bodyContainerView.snp.makeConstraints {
            $0.height.lessThanOrEqualTo(58)
        }
        
        bodyLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        imagesCollectionView.snp.makeConstraints {
            $0.height.equalTo(Layout.imageRowHeight)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        primaryMetadataStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        secondaryMetadataStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        images = []
        bodyHorizontalStackView.isHidden = true
        badgeImageView.kf.cancelDownloadTask()
        badgeImageView.image = nil
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
        imagesCollectionView.reloadData()
    }

    private func bindBodies(_ bodies: [HomeListCardBody]) {
        guard let body = bodies.first, !body.text.text.isEmpty else {
            bodyHorizontalStackView.isHidden = true
            return
        }
        bodyHorizontalStackView.isHidden = false
        bodyLabel.setSDText(body.text)
        bodyContainerView.setSDSurfaceStyle(body.style)
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
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: getImageWidth(), height: Layout.imageRowHeight)
    }
    
    private func getImageWidth() -> CGFloat {
        let itemCount = images.count
        let screenWidth = UIUtils.windowBounds.width
        let availableWidth = screenWidth - (Layout.horizontalInset * 2)
        
        if itemCount == 1 {
            return availableWidth
        } else if itemCount == 2 {
            let itemWidth = (availableWidth - Layout.imageSpacing) / 2
            return itemWidth
        } else {
            return Layout.imageRowHeight
        }
    }
}
