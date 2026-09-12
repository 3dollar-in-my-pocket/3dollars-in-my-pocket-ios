import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class StoreScreenPreviewCell: BaseCollectionViewCell {
    enum Layout {
        static let imageSpacing: CGFloat = 8
        static let actionBarSpacing: CGFloat = 4
        static let defaultImageSize: CGFloat = 120
    }

    var onAction: ((StoreSectionAction) -> Void)?
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 16, left: 0, bottom: 16, right: 0)
        stack.insetsLayoutMarginsFromSafeArea = false
        return stack
    }()
    private let topContentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
        stack.insetsLayoutMarginsFromSafeArea = false
        return stack
    }()
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.gray100.color
        return label
    }()
    private let badgeImageView = UIImageView()
    private let primaryMetadataStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }()
    private let secondaryMetadataStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }()
    private let contributorContainer = UIView()
    private let contributorButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 4, leading: 8, bottom: 4, trailing: 8)
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.titleLabel?.font = Fonts.regular.font(size: 14)
        return button
    }()
    private let actionCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.actionBarSpacing
        layout.minimumInteritemSpacing = Layout.actionBarSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        return collectionView
    }()
    private let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.imageSpacing
        layout.minimumInteritemSpacing = Layout.imageSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        return collectionView
    }()

    private var imageHeightConstraint: Constraint?
    private var images: [SDImage] = []
    private var actionBars: [SDActionBar] = []

    override func prepareForReuse() {
        super.prepareForReuse()
        contributorContainer.isHidden = true
        contributorButton.clear()
        contributorButton.removeTarget(nil, action: nil, for: .touchUpInside)
        actionBars = []
        actionCollectionView.isHidden = true
        actionCollectionView.reloadData()
        images = []
        imageHeightConstraint?.update(offset: 0)
        imageCollectionView.isHidden = true
        imageCollectionView.reloadData()
        onAction = nil
    }

    override func setup() {
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(badgeImageView)
        topContentStack.addArrangedSubview(titleStack)
        topContentStack.addArrangedSubview(primaryMetadataStack, previousSpace: 4)
        topContentStack.addArrangedSubview(secondaryMetadataStack, previousSpace: 0)

        contributorContainer.addSubview(contributorButton)
        topContentStack.addArrangedSubview(contributorContainer)

        actionCollectionView.register([StoreScreenPreviewActionCell.self])
        actionCollectionView.dataSource = self
        actionCollectionView.delegate = self

        imageCollectionView.register([StoreScreenPreviewImageCell.self])
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self

        contentStack.addArrangedSubview(topContentStack)
        contentStack.addArrangedSubview(actionCollectionView, previousSpace: 16)
        contentStack.addArrangedSubview(imageCollectionView)
        containerView.addSubview(contentStack)
        contentView.addSubview(containerView)
    }

    override func bindConstraints() {
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        primaryMetadataStack.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        secondaryMetadataStack.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        contentStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        badgeImageView.snp.makeConstraints { $0.size.lessThanOrEqualTo(24) }
        contributorButton.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(28)
        }
        actionCollectionView.snp.makeConstraints { $0.height.equalTo(StoreScreenPreviewActionCell.Layout.height) }
        imageCollectionView.snp.makeConstraints {
            imageHeightConstraint = $0.height.equalTo(0).constraint
        }
    }

    func bind(_ section: StoreScreenPreviewSection) {
        containerView.setSDSurfaceStyle(section.style)
        titleLabel.setSDText(section.header.title)
        badgeImageView.isHidden = section.header.badge == nil
        if let badge = section.header.badge {
            badgeImageView.setImage(urlString: badge.url)
            badgeImageView.snp.updateConstraints {
                $0.width.equalTo(badge.style.width)
                $0.height.equalTo(badge.style.height)
            }
        }
        
        bindMetadataStack(
            chips: section.metadata.primary,
            separator: section.metadata.separator,
            into: primaryMetadataStack
        )
        bindMetadataStack(
            chips: section.metadata.secondary,
            separator: section.metadata.separator,
            into: secondaryMetadataStack
        )

        bindContributorActionBar(section.contributorActionBar)
        bindActionBars(section.actionBars)

        bindImages(section.images)
    }
    
    private func bindImages(_ images: [SDImage]) {
        self.images = images

        let isEmpty = images.isEmpty
        let height = images.map { imageSize(for: $0).height }.max() ?? 0
        imageHeightConstraint?.update(offset: isEmpty ? 0 : height)
        imageCollectionView.isHidden = isEmpty
        imageCollectionView.collectionViewLayout.invalidateLayout()
        imageCollectionView.reloadData()
    }

    private func imageSize(for image: SDImage) -> CGSize {
        let width = image.style.width > 0 ? image.style.width : Layout.defaultImageSize
        let height = image.style.height > 0 ? image.style.height : Layout.defaultImageSize

        return CGSize(width: width, height: height)
    }

    private func bindContributorActionBar(_ actionBar: SDActionBar?) {
        contributorContainer.isHidden = actionBar == nil
        guard let actionBar else { return }

        contributorButton.setSDButton(actionBar.button)
        contributorButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = actionBar.storeSectionAction {
            contributorButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
    }

    private func bindActionBars(_ actionBars: [SDActionBar]) {
        self.actionBars = actionBars

        actionCollectionView.isHidden = actionBars.isEmpty
        actionCollectionView.collectionViewLayout.invalidateLayout()
        actionCollectionView.reloadData()
    }

    private func bindMetadataStack(
        chips: [SDChip],
        separator: SDImage,
        into stackView: UIStackView
    ) {
        stackView.isHidden = chips.isEmpty
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        chips.forEach { chip in
            let chipView = SDChipView(spacing: 2)
            chipView.bind(chip)
            stackView.addArrangedSubview(chipView)
            
            if chips.last != chip {
                let separatorImage = UIImageView()
                separatorImage.setSDImage(separator)
                stackView.addArrangedSubview(separatorImage)
            }
        }
        stackView.addArrangedSubview(UIView())
    }
}

// MARK: UICollectionViewDataSource
extension StoreScreenPreviewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == actionCollectionView {
            return actionBars.count
        }
        return images.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == actionCollectionView {
            let cell: StoreScreenPreviewActionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            if let actionBar = actionBars[safe: indexPath.item] {
                cell.bind(actionBar.button)
            }
            return cell
        }

        let cell: StoreScreenPreviewImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        if let image = images[safe: indexPath.item] {
            cell.bind(image)
        }
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension StoreScreenPreviewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == actionCollectionView {
            guard let actionBar = actionBars[safe: indexPath.item] else { return .zero }

            return StoreScreenPreviewActionCell.Layout.size(for: actionBar)
        }

        guard let image = images[safe: indexPath.item] else { return .zero }

        return imageSize(for: image)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == actionCollectionView,
              let action = actionBars[safe: indexPath.item]?.storeSectionAction else { return }
        onAction?(action)
    }
}
