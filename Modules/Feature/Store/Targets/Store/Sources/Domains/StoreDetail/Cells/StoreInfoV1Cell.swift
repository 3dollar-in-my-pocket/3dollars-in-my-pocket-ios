import UIKit

import Common
import DesignSystem
import Model
import SnapKit

/// INFO_V1 (유저 제보 가게의 가게 정보 및 메뉴) 섹션 셀.
final class StoreInfoV1Cell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let actionButton = UIButton(type: .system)
    private let contentStack = UIStackView()

    override func prepareForReuse() {
        super.prepareForReuse()
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
    }

    override func setup() {
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentView.addSubViews([titleLabel, actionButton, contentStack])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints { $0.top.leading.equalToSuperview() }
        actionButton.snp.makeConstraints { $0.top.trailing.equalToSuperview() }
        contentStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func bind(_ section: StoreInfoV1Section) {
        titleLabel.setSDText(section.header.title)
        actionButton.setOptionalSDButton(section.header.trailingAction)
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.header.trailingAction?.storeSectionAction {
            actionButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let card = section.informationCard {
            contentStack.addArrangedSubview(StoreInfoInformationCardView(card: card))
        }
        section.menuGroupCards.forEach {
            contentStack.addArrangedSubview(StoreInfoMenuGroupCardView(card: $0))
        }
    }
}

/// 아이콘 + 텍스트(+보조 텍스트)를 가로로 표시하는 SDChip 뷰.
final class StoreInfoChipView: UIView {
    init(chip: SDChip, font: UIFont = Fonts.medium.font(size: 13)) {
        super.init(frame: .zero)
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        addSubViews([stack])
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }

        if let image = chip.image {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.setSDImage(image)
            stack.addArrangedSubview(imageView)
            imageView.snp.makeConstraints {
                $0.width.equalTo(image.style.width)
                $0.height.equalTo(image.style.height)
            }
        }
        if let text = chip.text {
            let label = StoreSectionTextLabel(font: font)
            label.setSDText(text)
            stack.addArrangedSubview(label)
        }
        if let additionalText = chip.additionalText {
            let label = StoreSectionTextLabel(font: font)
            label.setSDText(additionalText)
            stack.addArrangedSubview(label)
        }
        if let style = chip.style {
            layer.cornerRadius = 8
            setSDChipStyle(style)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// 가게 정보 카드 (형태·결제방식·출몰시기 등 label + chips 행 목록).
private final class StoreInfoInformationCardView: UIView {
    init(card: InformationCard) {
        super.init(frame: .zero)
        layer.cornerRadius = 12
        setSDSurfaceStyle(card.style)

        let rowsStack = UIStackView()
        rowsStack.axis = .vertical
        rowsStack.spacing = 10
        addSubViews([rowsStack])
        rowsStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }
        card.rows.forEach { rowsStack.addArrangedSubview(makeRow($0)) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeRow(_ row: LabelChipRow) -> UIView {
        let view = UIView()
        let label = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
        label.setSDText(row.label)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        let chipsStack = UIStackView()
        chipsStack.axis = .horizontal
        chipsStack.alignment = .center
        chipsStack.spacing = 8
        row.chips.forEach { chipsStack.addArrangedSubview(StoreInfoChipView(chip: $0)) }

        view.addSubViews([label, chipsStack])
        label.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.width.greaterThanOrEqualTo(56)
        }
        chipsStack.snp.makeConstraints {
            $0.centerY.equalTo(label)
            $0.leading.equalTo(label.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        return view
    }
}

/// 메뉴 그룹 카드 (카테고리 chip 헤더 + 메뉴명/가격 목록).
private final class StoreInfoMenuGroupCardView: UIView {
    init(card: MenuGroupCard) {
        super.init(frame: .zero)
        layer.cornerRadius = 12
        setSDSurfaceStyle(card.style)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        addSubViews([stack])
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }

        stack.addArrangedSubview(StoreInfoChipView(chip: card.header, font: Fonts.semiBold.font(size: 14)))
        card.items.forEach { stack.addArrangedSubview(makeItemRow($0)) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeItemRow(_ item: TextMenuItem) -> UIView {
        let view = UIView()
        let primaryLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 14))
        primaryLabel.setSDText(item.primaryText)
        let secondaryLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 14))
        secondaryLabel.setSDText(item.secondaryText)
        secondaryLabel.textAlignment = .right

        view.addSubViews([primaryLabel, secondaryLabel])
        primaryLabel.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(secondaryLabel.snp.leading).offset(-8)
        }
        secondaryLabel.snp.makeConstraints {
            $0.centerY.equalTo(primaryLabel)
            $0.trailing.equalToSuperview()
        }
        secondaryLabel.setContentHuggingPriority(.required, for: .horizontal)
        secondaryLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }
}
