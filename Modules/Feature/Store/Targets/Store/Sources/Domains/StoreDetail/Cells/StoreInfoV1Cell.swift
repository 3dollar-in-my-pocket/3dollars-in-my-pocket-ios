import UIKit

import Common
import DesignSystem
import Model
import SnapKit

/// INFO_V1 (유저 제보 가게의 가게 정보 및 메뉴) 섹션 셀.
final class StoreInfoV1Cell: BaseCollectionViewCell {
    enum Layout {
        static let verticalMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 20
        static let cardCornerRadius: CGFloat = 20
        static let cardInset: CGFloat = 16
        /// 카테고리 헤더 + 메뉴 행이 이 개수를 넘으면 접고 "메뉴 N개 더보기"를 노출한다.
        static let collapsedMenuRowCount = 6
        static let moreButtonHeight: CGFloat = 50
    }

    var onAction: ((StoreSectionAction) -> Void)?
    /// 더보기 탭. 펼침 상태는 셀 재사용과 무관하게 유지돼야 하므로 호스트가 보관하고 다시 bind 한다.
    var onToggleMenuExpansion: (() -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let subTitleLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
    private let actionButton = UIButton(type: .system)
    private let contentStack = UIStackView()

    override func prepareForReuse() {
        super.prepareForReuse()
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
        onToggleMenuExpansion = nil
    }

    override func setup() {
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentView.addSubViews([titleLabel, subTitleLabel, actionButton, contentStack])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.verticalMargin)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
        }
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
        }
        actionButton.snp.makeConstraints {
            $0.centerY.equalTo(subTitleLabel)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
        }
        contentStack.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            $0.bottom.equalToSuperview().offset(-Layout.verticalMargin)
        }
    }

    func bind(_ section: StoreInfoV1Section, isMenuExpanded: Bool = false) {
        titleLabel.setSDText(section.header.title)
        subTitleLabel.setSDText(section.header.subTitle)
        subTitleLabel.isHidden = section.header.subTitle == nil
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
            let menuCardView = StoreInfoMenuCardView(card: menuCard, isExpanded: isMenuExpanded)
            menuCardView.onTapMore = { [weak self] in self?.onToggleMenuExpansion?() }
            contentStack.addArrangedSubview(menuCardView)
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
        stack.spacing = chip.contentSpacing.map { CGFloat($0) } ?? 4
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
        layer.cornerRadius = StoreInfoV1Cell.Layout.cardCornerRadius
        setSDSurfaceStyle(card.style)

        let rowsStack = UIStackView()
        rowsStack.axis = .vertical
        rowsStack.spacing = 8
        addSubViews([rowsStack])
        rowsStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(StoreInfoV1Cell.Layout.cardInset) }
        card.rows.forEach { row in
            guard let rowView = makeRow(row) else { return }
            rowsStack.addArrangedSubview(rowView)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeRow(_ row: InformationRow) -> UIView? {
        switch row {
        case .trailingText(let row):
            let valueLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
            valueLabel.setSDText(row.value)
            valueLabel.textAlignment = .right
            return makeRow(label: row.label, value: valueLabel)
        case .chipGroup(let row):
            let chipsStack = makeValueStack(spacing: 2)
            row.chips.forEach { chipsStack.addArrangedSubview(StoreInfoCircleChipView(chip: $0)) }
            return makeRow(label: row.label, value: chipsStack)
        case .inlineOption(let row):
            // 선택 여부는 서버가 텍스트 색으로 내려주므로 클라이언트는 불릿 색만 텍스트 색에 맞춘다.
            let itemsStack = makeValueStack(spacing: 4)
            row.items.forEach { itemsStack.addArrangedSubview(StoreInfoBulletTextView(text: $0.text)) }
            return makeRow(label: row.label, value: itemsStack)
        case .unknown:
            return nil
        }
    }

    private func makeValueStack(spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = spacing
        return stackView
    }

    private func makeRow(label: SDText, value: UIView) -> UIView {
        let view = UIView()
        let labelView = StoreSectionTextLabel(font: Fonts.bold.font(size: 12))
        labelView.setSDText(label)
        labelView.setContentHuggingPriority(.required, for: .horizontal)
        labelView.setContentCompressionResistancePriority(.required, for: .horizontal)

        view.addSubViews([labelView, value])
        view.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        labelView.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.width.greaterThanOrEqualTo(72)
        }
        value.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(labelView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview()
        }
        return view
    }
}

/// 출몰 시기 요일처럼 원형 배경 위에 글자 하나를 얹는 칩.
private final class StoreInfoCircleChipView: UIView {
    init(chip: SDChip) {
        super.init(frame: .zero)
        layer.cornerRadius = 12
        clipsToBounds = true
        if let style = chip.style {
            setSDChipStyle(style)
        }

        let label = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
        label.setSDText(chip.text)
        label.textAlignment = .center
        addSubViews([label])
        snp.makeConstraints { $0.size.equalTo(24) }
        label.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// 결제 방식처럼 불릿(4pt) + 텍스트로 표시되는 항목. 불릿 색은 텍스트 색을 따른다.
private final class StoreInfoBulletTextView: UIView {
    init(text: SDText?) {
        super.init(frame: .zero)
        let bulletView = UIView()
        bulletView.layer.cornerRadius = 2
        bulletView.backgroundColor = UIColor(hex: text?.fontColor ?? "") ?? Colors.gray40.color

        let label = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
        label.setSDText(text)

        addSubViews([bulletView, label])
        bulletView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(4)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(4)
        }
        label.snp.makeConstraints {
            $0.leading.equalTo(bulletView.snp.trailing).offset(4)
            $0.top.bottom.trailing.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// 메뉴 카드 (카테고리 chip 헤더 + 메뉴명/점선 리더/가격 목록의 그룹 묶음).
/// 서버는 메뉴를 전부 내려주므로, 행(헤더+메뉴)이 `collapsedMenuRowCount`를 넘으면 클라이언트가 접는다.
private final class StoreInfoMenuCardView: UIView {
    var onTapMore: (() -> Void)?

    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(Colors.gray60.color, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        return button
    }()

    init(card: MenuCard, isExpanded: Bool) {
        super.init(frame: .zero)
        layer.cornerRadius = StoreInfoV1Cell.Layout.cardCornerRadius
        setSDSurfaceStyle(card.style)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        addSubViews([stack])

        let totalRowCount = card.groups.reduce(0) { $0 + 1 + $1.items.count }
        let totalItemCount = card.groups.reduce(0) { $0 + $1.items.count }
        let isCollapsed = isExpanded.isNot && totalRowCount > StoreInfoV1Cell.Layout.collapsedMenuRowCount
        var remainingRowCount = isCollapsed ? StoreInfoV1Cell.Layout.collapsedMenuRowCount : totalRowCount
        var shownItemCount = 0

        // 접힌 상태에서 카테고리 헤더만 남고 메뉴가 잘리면 어색하므로, 헤더+메뉴 1개가 들어갈 때만 그룹을 연다.
        for group in card.groups where remainingRowCount >= 2 {
            let groupStack = UIStackView()
            groupStack.axis = .vertical
            groupStack.spacing = 8
            groupStack.addArrangedSubview(
                StoreInfoChipView(chip: group.header, font: Fonts.semiBold.font(size: 14))
            )
            remainingRowCount -= 1
            for item in group.items where remainingRowCount > 0 {
                groupStack.addArrangedSubview(makeItemRow(item))
                remainingRowCount -= 1
                shownItemCount += 1
            }
            stack.addArrangedSubview(groupStack)
        }

        guard isCollapsed else {
            stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(StoreInfoV1Cell.Layout.cardInset) }
            return
        }

        let divider = UIView()
        divider.backgroundColor = Colors.gray20.color
        moreButton.setTitle(Strings.StoreDetail.Menu.moreFormat(totalItemCount - shownItemCount), for: .normal)
        moreButton.addAction(UIAction { [weak self] _ in self?.onTapMore?() }, for: .touchUpInside)
        addSubViews([divider, moreButton])

        stack.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(StoreInfoV1Cell.Layout.cardInset)
        }
        divider.snp.makeConstraints {
            $0.top.equalTo(stack.snp.bottom).offset(StoreInfoV1Cell.Layout.cardInset)
            $0.leading.trailing.equalToSuperview().inset(StoreInfoV1Cell.Layout.cardInset)
            $0.height.equalTo(1)
        }
        moreButton.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(StoreInfoV1Cell.Layout.moreButtonHeight)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeItemRow(_ item: TextMenuItem) -> UIView {
        let view = UIView()
        let primaryLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
        primaryLabel.setSDText(item.primaryText)
        let secondaryLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))
        secondaryLabel.setSDText(item.secondaryText)
        secondaryLabel.textAlignment = .right
        let leaderLineView = DashedLineView()

        view.addSubViews([primaryLabel, leaderLineView, secondaryLabel])
        primaryLabel.snp.makeConstraints {
            // 그룹 헤더 아이콘(28) + 간격(8) 뒤 텍스트 시작점과 정렬한다.
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(36)
        }
        leaderLineView.snp.makeConstraints {
            $0.leading.equalTo(primaryLabel.snp.trailing).offset(8)
            $0.trailing.equalTo(secondaryLabel.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(1)
        }
        secondaryLabel.snp.makeConstraints {
            $0.centerY.equalTo(primaryLabel)
            $0.trailing.equalToSuperview()
        }
        primaryLabel.setContentHuggingPriority(.required, for: .horizontal)
        primaryLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        secondaryLabel.setContentHuggingPriority(.required, for: .horizontal)
        secondaryLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }
}

/// 메뉴명과 가격 사이를 잇는 점선 리더.
private final class DashedLineView: UIView {
    private let dashLayer = CAShapeLayer()

    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        dashLayer.strokeColor = Colors.gray30.color.cgColor
        dashLayer.lineWidth = 1
        dashLayer.lineDashPattern = [2, 2]
        layer.addSublayer(dashLayer)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        dashLayer.path = path.cgPath
        dashLayer.frame = bounds
    }
}
