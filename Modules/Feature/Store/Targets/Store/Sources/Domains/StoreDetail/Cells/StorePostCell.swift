import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StorePostCell: BaseCollectionViewCell {
    enum Layout {
        static let verticalMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 20
        static let contentSpacing: CGFloat = 12
    }

    var onAction: ((StoreSectionAction) -> Void)?
    var onToggleBodyExpansion: ((String) -> Void)?
    var onTapImage: (([SDImage], Int) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let actionButton = UIButton(type: .system)
    private let cardStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.contentSpacing
        return stackView
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        cardStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
        onToggleBodyExpansion = nil
        onTapImage = nil
    }

    override func setup() {
        contentView.addSubViews([titleLabel, actionButton, cardStack])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.verticalMargin)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-8)
        }
        actionButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
        }
        cardStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Layout.contentSpacing)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            $0.bottom.equalToSuperview().offset(-Layout.verticalMargin)
        }
    }

    func bind(_ section: StorePostSection, expandedCardIds: Set<String> = []) {
        titleLabel.setSDText(section.header.title, lineHeight: 24)
        actionButton.setOptionalSDButton(section.header.trailingAction)
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.header.trailingAction?.storeSectionAction {
            actionButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
        cardStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.cards.forEach { card in
            let cardView = StorePostCardView(card: card, isBodyExpanded: expandedCardIds.contains(card.cardId))
            cardView.onAction = { [weak self] action in self?.onAction?(action) }
            cardView.onTapBody = { [weak self] in self?.onToggleBodyExpansion?(card.cardId) }
            cardView.onTapImage = { [weak self] index in self?.onTapImage?(card.images, index) }
            cardStack.addArrangedSubview(cardView)
        }
    }
}

private final class StorePostCardView: UIView {
    enum Layout {
        static let cornerRadius: CGFloat = 16
        static let inset: CGFloat = 16
        static let contentSpacing: CGFloat = 12
        static let headerIconSize: CGFloat = 40
        static let headerSpacing: CGFloat = 8
        static let imageHeight: CGFloat = 208
        static let imageSpacing: CGFloat = 12
        static let imageCornerRadius: CGFloat = 8
        static let bodyMaxLines = 6
        static let bodyFont = Fonts.regular.font(size: 14)
        static let bodyLineHeight: CGFloat = 20
        static let moreText = "더보기"
        static let shorteningText = " ... "
    }

    var onAction: ((StoreSectionAction) -> Void)?
    var onTapBody: (() -> Void)?
    var onTapImage: ((Int) -> Void)?

    private let contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.contentSpacing
        return stackView
    }()

    private let headerIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Layout.headerIconSize / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    private let headerTitleLabel: StoreSectionTextLabel = {
        let label = StoreSectionTextLabel(font: Fonts.bold.font(size: 14))
        label.numberOfLines = 1
        return label
    }()
    private let headerSubtitleLabel: StoreSectionTextLabel = {
        let label = StoreSectionTextLabel(font: Fonts.regular.font(size: 12))
        label.numberOfLines = 1
        return label
    }()

    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.imageSpacing
        layout.minimumInteritemSpacing = Layout.imageSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: Layout.inset, bottom: 0, right: Layout.inset)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.decelerationRate = .fast
        view.register([StorePostImageCell.self])
        view.dataSource = self
        view.delegate = self
        return view
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()

    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentHorizontalAlignment = .leading
        return button
    }()

    private let card: StorePostContentCard
    private let isBodyExpanded: Bool
    private var isBodyTruncated = false

    init(card: StorePostContentCard, isBodyExpanded: Bool) {
        self.card = card
        self.isBodyExpanded = isBodyExpanded
        super.init(frame: .zero)
        setupViews()
        bindConstraints()
        bind()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        layer.cornerRadius = Layout.cornerRadius
        clipsToBounds = true
        setSDSurfaceStyle(card.style)

        let headerTextStack = UIStackView()
        headerTextStack.axis = .vertical
        headerTextStack.addArrangedSubview(headerTitleLabel)
        headerTextStack.addArrangedSubview(headerSubtitleLabel)

        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = Layout.headerSpacing
        headerStack.addArrangedSubview(headerIconImageView)
        headerStack.addArrangedSubview(headerTextStack)

        let headerContainer = makeInsetContainer()
        headerContainer.addSubview(headerStack)
        headerStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(headerContainer.layoutMarginsGuide)
            $0.trailing.lessThanOrEqualTo(headerContainer.layoutMarginsGuide)
        }

        let bodyContainer = makeInsetContainer()
        bodyContainer.addSubview(bodyLabel)
        bodyLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalTo(bodyContainer.layoutMarginsGuide)
        }

        let likeContainer = makeInsetContainer()
        likeContainer.addSubview(likeButton)
        likeButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(likeContainer.layoutMarginsGuide)
            $0.trailing.lessThanOrEqualTo(likeContainer.layoutMarginsGuide)
        }

        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.insetsLayoutMarginsFromSafeArea = false
        contentStack.layoutMargins = UIEdgeInsets(top: Layout.inset, left: 0, bottom: Layout.inset, right: 0)
        [headerContainer, imageCollectionView, bodyContainer, likeContainer].forEach {
            contentStack.addArrangedSubview($0)
        }
        addSubview(contentStack)

        bodyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBody)))
        likeButton.addAction(UIAction { [weak self] _ in self?.didTapLike() }, for: .touchUpInside)
        if card.link != nil {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
            gesture.cancelsTouchesInView = false
            addGestureRecognizer(gesture)
        }
    }

    private func makeInsetContainer() -> UIView {
        let container = UIView()
        container.insetsLayoutMarginsFromSafeArea = false
        container.layoutMargins = UIEdgeInsets(top: 0, left: Layout.inset, bottom: 0, right: Layout.inset)
        return container
    }

    private func bindConstraints() {
        contentStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        headerIconImageView.snp.makeConstraints { $0.size.equalTo(Layout.headerIconSize) }
        imageCollectionView.snp.makeConstraints { $0.height.equalTo(Layout.imageHeight) }
    }

    private func bind() {
        if let image = card.header.image {
            headerIconImageView.setImage(urlString: image.url)
            headerIconImageView.isHidden = false
        } else {
            headerIconImageView.isHidden = true
        }
        headerTitleLabel.setSDText(card.header.text, lineHeight: 20)
        headerSubtitleLabel.setSDText(card.header.additionalText, lineHeight: 18)
        headerSubtitleLabel.isHidden = card.header.additionalText == nil

        imageCollectionView.isHidden = card.images.isEmpty
        imageCollectionView.reloadData()

        bindBody()

        let like = card.like
        likeButton.setOptionalSDButton(like?.isSelected == true ? like?.selected : like?.unselected)
        likeButton.isHidden = like == nil
    }

    private func bindBody() {
        let plainText = StorePostCardView.plainText(from: card.body)
        let textColor = UIColor(hex: card.body.fontColor) ?? Colors.gray95.color
        let attributes = StorePostCardView.bodyAttributes(color: textColor)
        let fullText = NSAttributedString(string: plainText, attributes: attributes)

        if isBodyExpanded {
            bodyLabel.attributedText = fullText
            isBodyTruncated = false
            return
        }

        let limited = StorePostCardView.limitedText(fullText: fullText, attributes: attributes)
        bodyLabel.attributedText = limited.text
        isBodyTruncated = limited.isTruncated
    }

    private static func plainText(from body: SDText) -> String {
        guard body.isHtml else { return body.text }
        return body.text
            .replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: [.regularExpression, .caseInsensitive])
            .htmlStripped
    }

    private static func bodyAttributes(color: UIColor) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.minimumLineHeight = Layout.bodyLineHeight
        paragraphStyle.maximumLineHeight = Layout.bodyLineHeight
        return [.font: Layout.bodyFont, .foregroundColor: color, .paragraphStyle: paragraphStyle]
    }

    private static var bodyWidth: CGFloat {
        UIUtils.windowBounds.width - StorePostCell.Layout.horizontalMargin * 2 - Layout.inset * 2
    }

    private static func limitedText(
        fullText: NSAttributedString,
        attributes: [NSAttributedString.Key: Any]
    ) -> (text: NSAttributedString, isTruncated: Bool) {
        let width = bodyWidth
        let framesetter = CTFramesetterCreateWithAttributedString(fullText)
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
        // swiftlint:disable:next force_cast
        let lines = CTFrameGetLines(frame) as! [CTLine]
        guard lines.count > Layout.bodyMaxLines else {
            return (fullText, false)
        }

        let truncatedText = NSMutableAttributedString()
        for line in lines.prefix(Layout.bodyMaxLines - 1) {
            let range = CTLineGetStringRange(line)
            truncatedText.append(fullText.attributedSubstring(from: NSRange(location: range.location, length: range.length)))
        }

        guard let lastLine = lines[safe: Layout.bodyMaxLines - 1] else { return (fullText, false) }
        let lastRange = CTLineGetStringRange(lastLine)
        var lastLineText = fullText
            .attributedSubstring(from: NSRange(location: lastRange.location, length: lastRange.length))
            .string
            .trimmingCharacters(in: .newlines)

        let boundingSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        while lastLineText.isEmpty.isNot,
              (lastLineText + Layout.shorteningText + Layout.moreText)
                .boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                .height > Layout.bodyLineHeight {
            lastLineText.removeLast()
        }

        let finalText = NSMutableAttributedString(
            string: lastLineText + Layout.shorteningText + Layout.moreText,
            attributes: attributes
        )
        let moreRange = NSRange(location: finalText.length - Layout.moreText.count, length: Layout.moreText.count)
        finalText.addAttribute(.foregroundColor, value: Colors.gray40.color, range: moreRange)
        finalText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: moreRange)
        truncatedText.append(finalText)
        return (truncatedText, true)
    }

    @objc private func didTapBody() {
        guard isBodyTruncated else {
            didTapCard()
            return
        }
        onTapBody?()
    }

    @objc private func didTapCard() {
        guard let link = card.link else { return }
        onAction?(.link(link, clickLog: card.clickLog))
    }

    private func didTapLike() {
        guard let like = card.like, let action = like.storeSectionAction(isSelected: like.isSelected) else { return }
        FeedbackGenerator.shared.generate(.impact)
        onAction?(action)
    }
}

extension StorePostCardView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        card.images.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: StorePostImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        if let image = card.images[safe: indexPath.item] {
            cell.bind(image)
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let image = card.images[safe: indexPath.item], image.style.height > 0 else {
            return CGSize(width: Layout.imageHeight, height: Layout.imageHeight)
        }
        let ratio = image.style.width / image.style.height
        return CGSize(width: Layout.imageHeight * ratio, height: Layout.imageHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTapImage?(indexPath.item)
    }
}

private final class StorePostImageCell: BaseCollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Colors.gray10.color
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = StorePostCardView.Layout.imageCornerRadius
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
