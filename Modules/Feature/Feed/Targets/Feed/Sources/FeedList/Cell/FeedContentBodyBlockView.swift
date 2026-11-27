import UIKit

import Common
import Model

import SnapKit

final class FeedContentBodyBlockView: BaseView {
    enum Layout {
        static let horizontalInset: CGFloat = 12
        static let verticalInset: CGFloat = 12
        static let compactVerticalInset: CGFloat = 8
        static let spacing: CGFloat = 8
        static let headingHeight: CGFloat = 20
        static let iconSize: CGFloat = 16
        static let imageSpacing: CGFloat = 8
        static let imageCornerRadius: CGFloat = 8
        static let textMaxLines = 5

        static func makeTextLabel() -> UILabel {
            let label = UILabel()
            label.font = Fonts.regular.font(size: 14)
            label.textColor = Colors.gray80.color
            label.numberOfLines = textMaxLines
            return label
        }
    }

    var onTapImage: ((Int) -> Void)?

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.spacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = false
        return stackView
    }()

    private let headingView = UIView()

    private let headingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    private let headingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let headingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 12)
        label.textColor = Colors.gray80.color
        return label
    }()

    private let trailingImagesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stackView
    }()

    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.imageSpacing
        layout.minimumInteritemSpacing = Layout.imageSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: Layout.horizontalInset, bottom: 0, right: Layout.horizontalInset)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([ImageCell.self])
        return collectionView
    }()

    private let textView = UIView()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    private let textLeadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let textLabel = Layout.makeTextLabel()

    private var images: [SDImage] = []
    private var imageHeightConstraint: Constraint?

    override func setup() {
        layer.cornerRadius = 12
        layer.masksToBounds = true

        addSubview(stackView)
        headingView.addSubViews([headingStackView, trailingImagesStackView])
        headingStackView.addArrangedSubview(headingImageView)
        headingStackView.addArrangedSubview(headingTitleLabel)
        textView.addSubview(textStackView)
        textStackView.addArrangedSubview(textLeadingImageView)
        textStackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(headingView)
        stackView.addArrangedSubview(imageCollectionView)
        stackView.addArrangedSubview(textView)
    }

    override func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        headingView.snp.makeConstraints {
            $0.height.equalTo(Layout.headingHeight)
        }

        headingStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(trailingImagesStackView.snp.leading).offset(-8)
        }

        trailingImagesStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Layout.horizontalInset)
            $0.centerY.equalToSuperview()
        }

        headingImageView.snp.makeConstraints {
            $0.size.equalTo(Layout.iconSize)
        }

        imageCollectionView.snp.makeConstraints {
            imageHeightConstraint = $0.height.equalTo(0).constraint
        }

        textStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalInset)
        }

        textLeadingImageView.snp.makeConstraints {
            $0.size.equalTo(Layout.iconSize)
        }
    }

    func bind(block: HomeNewsBodyBlock) {
        backgroundColor = block.style.flatMap { UIColor(hex: $0.backgroundColor) }
        if let border = block.style?.border, let borderColor = UIColor(hex: border.color) {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = border.width
        } else {
            layer.borderWidth = 0
        }

        bindHeading(block.heading)
        bindImages(block.images)
        bindText(block)

        let verticalInset = block.heading == nil && block.images.isEmpty
            ? Layout.compactVerticalInset
            : Layout.verticalInset
        stackView.layoutMargins = UIEdgeInsets(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
    }

    private func bindHeading(_ heading: HomeNewsBodyBlockHeading?) {
        headingView.isHidden = heading == nil
        guard let heading else { return }

        headingImageView.isHidden = heading.leadingImage == nil
        headingImageView.clear()
        headingImageView.setImage(urlString: heading.leadingImage?.url)
        headingTitleLabel.setSDText(heading.title)

        trailingImagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        heading.trailingImages.forEach { image in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.setSDImage(image)
            trailingImagesStackView.addArrangedSubview(imageView)
        }
    }

    private func bindImages(_ images: [SDImage]) {
        self.images = images
        imageCollectionView.isHidden = images.isEmpty
        let height = images.map { CGFloat($0.style.height) }.max() ?? 0
        imageHeightConstraint?.update(offset: height)
        imageCollectionView.reloadData()
    }

    private func bindText(_ block: HomeNewsBodyBlock) {
        textView.isHidden = block.text == nil
        textLeadingImageView.isHidden = block.textLeadingImage == nil
        textLeadingImageView.clear()
        textLeadingImageView.setImage(urlString: block.textLeadingImage?.url)
        textLabel.setSDText(block.text)
    }
}

extension FeedContentBodyBlockView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        if let image = images[safe: indexPath.item] {
            cell.bind(image: image)
        }
        return cell
    }
}

extension FeedContentBodyBlockView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let image = images[safe: indexPath.item] else { return .zero }
        return CGSize(width: image.style.width, height: image.style.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTapImage?(indexPath.item)
    }
}

extension FeedContentBodyBlockView {
    private final class ImageCell: BaseCollectionViewCell {
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = Colors.gray10.color
            imageView.layer.cornerRadius = Layout.imageCornerRadius
            imageView.layer.masksToBounds = true
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
            imageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }

        func bind(image: SDImage) {
            imageView.setImage(urlString: image.url)
            imageView.alpha = image.style.dimmed ? 0.5 : CGFloat(image.style.alpha)
        }
    }
}
