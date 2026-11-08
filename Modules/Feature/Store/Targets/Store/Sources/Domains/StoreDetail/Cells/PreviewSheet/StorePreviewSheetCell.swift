import UIKit

import Common
import DesignSystem
import Model
import StoreInterface

import SnapKit

/// 홈 미리보기 시트(tip)의 PREVIEW 섹션 셀. 상세의 `StoreScreenPreviewCell` 과 같은 섹션을 시트 디자인으로 그린다.
final class StorePreviewSheetCell: BaseCollectionViewCell {
    enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let titleHeight: CGFloat = 28
        static let topButtonSize: CGFloat = 32
        static let actionBarHeight: CGFloat = 36
        static let imageSpacing: CGFloat = 8
        static let defaultImageSize = CGSize(width: 158, height: 158)
        static let bodySize = CGSize(width: 300, height: 58)
    }

    var onEvent: ((StorePreviewSectionsEvent) -> Void)?

    private let rootStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        return stack
    }()

    private let titleRow = UIView()

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
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let badgeImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    private let topButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private let saveButton = StorePreviewSheetCell.makeIconButton(icon: Icons.bookmarkLine.image)
    private let closeButton = StorePreviewSheetCell.makeIconButton(icon: Icons.close.image)

    private let metadataContainer = UIView()
    private let metadataView = StorePreviewMetadataRowView()

    private let actionBarScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.bounces = false
        scroll.contentInset = UIEdgeInsets(top: 0, left: Layout.horizontalMargin, bottom: 0, right: Layout.horizontalMargin)
        return scroll
    }()

    private let actionBarStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.distribution = .fill
        return stack
    }()

    private let imagesContainer = UIView()

    private let imagesCollectionView: UICollectionView = {
        let layout = WidthAdaptiveFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.imageSpacing
        layout.minimumInteritemSpacing = Layout.imageSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        return collectionView
    }()

    private let bodiesScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.bounces = false
        return scroll
    }()

    private let bodiesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private var imagesHeightConstraint: Constraint?
    private var imageItems: [SDImage] = []
    /// "사진 추가" 셀 노출 여부. 사장님 가게는 사용자 사진 업로드를 지원하지 않아 false 로 둔다.
    private var canAddPhoto = false

    override func prepareForReuse() {
        super.prepareForReuse()
        onEvent = nil
        titleLabel.attributedText = nil
        titleLabel.text = nil
        configureBadge(nil)
        metadataView.clear()
        actionBarStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        configureImages([])
        configureBodies([])
    }

    override func setup() {
        contentView.addSubview(rootStack)
        contentView.addSubview(topButtonStack)

        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(badgeImageView)
        titleRow.addSubview(titleStack)

        topButtonStack.addArrangedSubview(saveButton)
        topButtonStack.addArrangedSubview(closeButton)

        metadataContainer.addSubview(metadataView)
        actionBarScrollView.addSubview(actionBarStack)
        imagesContainer.addSubview(imagesCollectionView)
        bodiesScrollView.addSubview(bodiesStack)

        rootStack.addArrangedSubview(titleRow)
        rootStack.addArrangedSubview(metadataContainer)
        rootStack.addArrangedSubview(actionBarScrollView)
        rootStack.addArrangedSubview(imagesContainer)
        rootStack.addArrangedSubview(bodiesScrollView)
        rootStack.setCustomSpacing(4, after: titleRow)
        rootStack.setCustomSpacing(12, after: metadataContainer)
        rootStack.setCustomSpacing(12, after: actionBarScrollView)
        rootStack.setCustomSpacing(8, after: imagesContainer)

        imagesCollectionView.register([StorePreviewImageCell.self, StorePreviewAddPhotoCell.self])
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self

        saveButton.addAction(UIAction { [weak self] _ in self?.onEvent?(.tapSave) }, for: .touchUpInside)
        closeButton.addAction(UIAction { [weak self] _ in self?.onEvent?(.tapClose) }, for: .touchUpInside)

        let bodyTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBody))
        bodyTapGesture.cancelsTouchesInView = false
        bodyTapGesture.delegate = self
        contentView.addGestureRecognizer(bodyTapGesture)
    }

    override func bindConstraints() {
        rootStack.snp.makeConstraints { $0.edges.equalToSuperview() }

        titleRow.snp.makeConstraints { $0.height.equalTo(Layout.titleHeight) }

        titleStack.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.top.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(topButtonStack.snp.leading).offset(-4)
        }

        saveButton.snp.makeConstraints { $0.size.equalTo(Layout.topButtonSize) }
        closeButton.snp.makeConstraints { $0.size.equalTo(Layout.topButtonSize) }

        topButtonStack.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            $0.height.equalTo(Layout.topButtonSize)
        }

        metadataView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Layout.horizontalMargin)
        }

        actionBarScrollView.snp.makeConstraints { $0.height.equalTo(Layout.actionBarHeight) }

        actionBarStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        imagesCollectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            imagesHeightConstraint = $0.height.equalTo(0).constraint
        }

        bodiesScrollView.snp.makeConstraints { $0.height.equalTo(Layout.bodySize.height) }

        bodiesStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.height.equalToSuperview()
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
        }
    }

    func bind(_ section: StoreScreenPreviewSection, isFavorited: Bool) {
        if let title = section.header.title {
            titleLabel.setSDText(title)
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = nil
        }
        configureBadge(section.header.badge)
        metadataView.configure(section.metadata)
        configureActionBars(section.actionBars)
        canAddPhoto = isBossStore(section).isNot
        configureImages(section.images)
        configureBodies(section.bodies ?? [])
        setFavorited(isFavorited)
    }

    private func isBossStore(_ section: StoreScreenPreviewSection) -> Bool {
        guard let rawValue = section.additionalInfos.storeType else { return false }
        return StoreType(value: rawValue) == .bossStore
    }

    func setFavorited(_ isFavorited: Bool) {
        let icon = isFavorited ? Icons.bookmarkSolid.image : Icons.bookmarkLine.image
        let color = isFavorited ? Colors.mainRed.color : Colors.gray100.color
        saveButton.setImage(icon.resizeImage(scaledTo: 20).withTintColor(color), for: .normal)
    }

    private func configureBadge(_ badge: SDImage?) {
        guard let badge else {
            badgeImageView.isHidden = true
            badgeImageView.image = nil
            return
        }
        badgeImageView.isHidden = false
        badgeImageView.setSDImage(badge)
    }

    private func configureActionBars(_ bars: [SDActionBar]) {
        actionBarStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, bar) in bars.enumerated() {
            let button = makeActionBarButton()
            button.setSDButton(bar.button)
            button.addAction(UIAction { [weak self] _ in
                self?.onEvent?(.tapActionBar(index: index))
            }, for: .touchUpInside)
            actionBarStack.addArrangedSubview(button)
        }
        actionBarScrollView.setContentOffset(CGPoint(x: -Layout.horizontalMargin, y: 0), animated: false)
    }

    private func configureImages(_ images: [SDImage]) {
        imageItems = images

        let hasImages = images.isEmpty.isNot
        let height = PreviewImageLayout.rowHeight(images: images, defaultHeight: Layout.defaultImageSize.height)
        imagesHeightConstraint?.update(offset: hasImages ? height : 0)
        imagesContainer.isHidden = hasImages.isNot
        imagesCollectionView.collectionViewLayout.invalidateLayout()
        imagesCollectionView.reloadData()
        if hasImages {
            imagesCollectionView.setContentOffset(.zero, animated: false)
        }
    }

    private func configureBodies(_ bodies: [StorePreviewBody]) {
        bodiesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        bodiesScrollView.isHidden = bodies.isEmpty

        for body in bodies {
            let card = StorePreviewBodyCardView()
            card.configure(body: body)
            card.snp.makeConstraints {
                $0.width.equalTo(Layout.bodySize.width)
                $0.height.equalTo(Layout.bodySize.height)
            }
            bodiesStack.addArrangedSubview(card)
        }
    }

    @objc private func didTapBody() {
        onEvent?(.tapBody)
    }

    /// 우상단 32pt 원형 아이콘 버튼(찜·닫기 공용). 배경 gray10, 아이콘 20pt·gray100.
    private static func makeIconButton(icon: UIImage) -> UIButton {
        let button = UIButton()
        button.backgroundColor = Colors.gray10.color
        button.layer.cornerRadius = Layout.topButtonSize / 2
        button.clipsToBounds = true
        button.setImage(icon.resizeImage(scaledTo: 20).withTintColor(Colors.gray100.color), for: .normal)
        return button
    }

    private func makeActionBarButton() -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = Layout.actionBarHeight / 2
        button.clipsToBounds = true
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)

        // 이미지와 타이틀 사이 4pt 간격을 만들기 위한 표준 트릭(semanticContentAttribute 가 .forceRightToLeft 이면 자동 반전).
        let halfSpacing: CGFloat = 2
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12 + halfSpacing, bottom: 8, right: 12 + halfSpacing)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: halfSpacing, bottom: 0, right: -halfSpacing)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -halfSpacing, bottom: 0, right: halfSpacing)

        button.snp.makeConstraints { $0.height.greaterThanOrEqualTo(Layout.actionBarHeight) }
        return button
    }
}

// MARK: UIGestureRecognizerDelegate
extension StorePreviewSheetCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 버튼(UIControl)과 이미지 목록(셀 탭을 직접 처리) 위의 터치는 상세 확장으로 처리하지 않는다.
        var hitView = touch.view
        while let current = hitView, current !== contentView {
            if current is UIControl { return false }
            if current === imagesCollectionView { return false }
            hitView = current.superview
        }
        return true
    }
}

// MARK: UICollectionViewDataSource & Delegate
extension StorePreviewSheetCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard imageItems.isEmpty.isNot else { return 0 }
        // 이미지가 있고 사진 추가가 가능한 가게(일반 가게)일 때만 마지막에 "사진 추가" 셀을 붙인다.
        return imageItems.count + (canAddPhoto ? 1 : 0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let image = imageItems[safe: indexPath.item] {
            let cell: StorePreviewImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(image)
            return cell
        }

        let cell: StorePreviewAddPhotoCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let rowHeight = PreviewImageLayout.rowHeight(images: imageItems, defaultHeight: Layout.defaultImageSize.height)
        guard imageItems[safe: indexPath.item] != nil else {
            return CGSize(width: rowHeight, height: rowHeight)
        }

        return PreviewImageLayout.itemSize(
            style: imageItems[safe: indexPath.item]?.style,
            count: imageItems.count,
            availableWidth: collectionView.bounds.width,
            spacing: Layout.imageSpacing,
            defaultSize: Layout.defaultImageSize
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if imageItems[safe: indexPath.item] != nil {
            onEvent?(.tapImage(index: indexPath.item))
        } else {
            onEvent?(.tapAddPhoto)
        }
    }
}
