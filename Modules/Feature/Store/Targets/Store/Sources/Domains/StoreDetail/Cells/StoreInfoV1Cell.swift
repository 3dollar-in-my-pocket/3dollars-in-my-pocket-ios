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
        if let menuCard = section.menuCard {
            contentStack.addArrangedSubview(StoreInfoMenuCardView(card: menuCard))
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

/// 가게 정보 카드 (가게형태·출몰시기·결제방식 등 label + 값 행 목록).
/// 행은 서버가 `type` 으로 구분해 내려주며 값 영역의 표현만 타입별로 달라진다.
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
        card.rows.forEach { row in
            guard let rowView = makeRow(row) else { return }
            rowsStack.addArrangedSubview(rowView)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeRow(_ row: InformationRow) -> UIView? {
        switch row {
        case .trailingText(let row):
            let valueLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
            valueLabel.setSDText(row.value)
            valueLabel.textAlignment = .right
            return makeRow(label: row.label, value: valueLabel, alignsTrailing: true)
        case .chipGroup(let row):
            let chipsStack = makeValueStack()
            row.chips.forEach { chipsStack.addArrangedSubview(StoreInfoChipView(chip: $0)) }
            return makeRow(label: row.label, value: chipsStack, alignsTrailing: false)
        case .inlineOption(let row):
            // 선택 여부는 서버가 텍스트 색으로 내려주므로 클라이언트는 순서대로 나열만 한다.
            let itemsStack = makeValueStack()
            row.items.forEach { item in
                let label = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
                label.setSDText(item.text)
                itemsStack.addArrangedSubview(label)
            }
            return makeRow(label: row.label, value: itemsStack, alignsTrailing: false)
        case .unknown:
            return nil
        }
    }

    private func makeValueStack() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }

    private func makeRow(label: SDText, value: UIView, alignsTrailing: Bool) -> UIView {
        let view = UIView()
        let labelView = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
        labelView.setSDText(label)
        labelView.setContentHuggingPriority(.required, for: .horizontal)
        labelView.setContentCompressionResistancePriority(.required, for: .horizontal)

        view.addSubViews([labelView, value])
        labelView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.width.greaterThanOrEqualTo(56)
        }
        value.snp.makeConstraints {
            $0.centerY.equalTo(labelView)
            $0.leading.equalTo(labelView.snp.trailing).offset(12)

            if alignsTrailing {
                $0.trailing.equalToSuperview()
            } else {
                $0.trailing.lessThanOrEqualToSuperview()
            }
        }
        return view
    }
}

/// 메뉴 카드 (카테고리 chip 헤더 + 메뉴명/가격 목록의 그룹 묶음).
private final class StoreInfoMenuCardView: UIView {
    init(card: MenuCard) {
        super.init(frame: .zero)
        layer.cornerRadius = 12
        setSDSurfaceStyle(card.style)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        addSubViews([stack])
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }

        card.groups.forEach { group in
            let groupStack = UIStackView()
            groupStack.axis = .vertical
            groupStack.spacing = 8
            groupStack.addArrangedSubview(
                StoreInfoChipView(chip: group.header, font: Fonts.semiBold.font(size: 14))
            )
            group.items.forEach { groupStack.addArrangedSubview(makeItemRow($0)) }
            stack.addArrangedSubview(groupStack)
        }
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
