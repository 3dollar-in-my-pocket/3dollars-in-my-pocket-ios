import UIKit

import Common
import DesignSystem
import Model
import SnapKit

/// INFO_V2 (사장님 가게의 가게 정보 및 메뉴) 섹션 셀.
final class StoreInfoV2Cell: BaseCollectionViewCell {
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

    func bind(_ section: StoreInfoV2Section) {
        titleLabel.setSDText(section.header.title)
        actionButton.setOptionalSDButton(section.header.trailingAction)
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.header.trailingAction?.storeSectionAction {
            actionButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let gallery = section.imageGallery, gallery.images.isNotEmpty {
            contentStack.addArrangedSubview(StoreInfoImageGalleryView(gallery: gallery))
        }
        if let detailCard = section.detailCard {
            contentStack.addArrangedSubview(StoreInfoDetailCardView(card: detailCard) { [weak self] action in
                self?.onAction?(action)
            })
        }
        section.accountCards.forEach { card in
            contentStack.addArrangedSubview(StoreInfoAccountCardView(card: card) { [weak self] action in
                self?.onAction?(action)
            })
        }
        if let menuListCard = section.menuListCard {
            contentStack.addArrangedSubview(StoreInfoMenuListCardView(card: menuListCard) { [weak self] action in
                self?.onAction?(action)
            })
        }
    }
}

/// 가게 사진 가로 스크롤 갤러리.
private final class StoreInfoImageGalleryView: UIView {
    init(gallery: ImageGallery) {
        super.init(frame: .zero)
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8

        addSubViews([scrollView])
        scrollView.addSubview(stack)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(96)
        }
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        gallery.images.forEach { image in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.setImage(urlString: image.url)
            stack.addArrangedSubview(imageView)
            // 서버 style 비율을 유지하되 높이는 96으로 고정한다.
            let ratio = image.style.height > 0 ? image.style.width / image.style.height : 1
            imageView.snp.makeConstraints { $0.width.equalTo(imageView.snp.height).multipliedBy(ratio) }
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// SNS 링크·사장님 한마디 등 LINK/TEXT 행으로 구성된 상세 카드.
private final class StoreInfoDetailCardView: UIView {
    private let onAction: (StoreSectionAction) -> Void

    init(card: DetailCard, onAction: @escaping (StoreSectionAction) -> Void) {
        self.onAction = onAction
        super.init(frame: .zero)
        layer.cornerRadius = 12
        setSDSurfaceStyle(card.style)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        addSubViews([stack])
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }

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
        let label = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
        label.setSDText(row.label)
        let valueLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
        valueLabel.setSDText(row.value)
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 1
        valueLabel.lineBreakMode = .byTruncatingTail

        control.addSubViews([label, valueLabel])
        label.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.width.greaterThanOrEqualTo(56)
        }
        valueLabel.snp.makeConstraints {
            $0.centerY.equalTo(label)
            $0.leading.equalTo(label.snp.trailing).offset(12)
            $0.trailing.equalToSuperview()
        }
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        control.addAction(UIAction { [weak self] _ in
            self?.onAction(.link(row.link, clickLog: nil))
        }, for: .touchUpInside)
        return control
    }

    private func makeTextRow(_ row: DetailTextRow) -> UIView {
        let view = UIView()
        let titleLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
        titleLabel.setSDText(row.title)
        let bodyLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 13))
        bodyLabel.setSDText(row.body)

        view.addSubViews([titleLabel, bodyLabel])
        titleLabel.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
        bodyLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        return view
    }
}

/// 계좌번호 카드. 서버에 계좌 복사 전용 액션이 없어 복사는 클라이언트에서 직접 수행한다.
private final class StoreInfoAccountCardView: UIView {
    private let card: AccountCopyCard
    private let onAction: (StoreSectionAction) -> Void

    init(card: AccountCopyCard, onAction: @escaping (StoreSectionAction) -> Void) {
        self.card = card
        self.onAction = onAction
        super.init(frame: .zero)
        layer.cornerRadius = 12
        setSDSurfaceStyle(card.style)

        let titleLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
        titleLabel.setSDText(card.title)
        let accountChip = StoreInfoChipView(chip: card.account, font: Fonts.semiBold.font(size: 14))
        let copyButton = UIButton(type: .system)
        copyButton.setSDButton(card.copyButton)
        copyButton.addAction(UIAction { [weak self] _ in self?.didTapCopy() }, for: .touchUpInside)

        addSubViews([titleLabel, accountChip, copyButton])
        titleLabel.snp.makeConstraints { $0.top.leading.equalToSuperview().inset(14) }
        accountChip.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(14)
            $0.trailing.lessThanOrEqualTo(copyButton.snp.leading).offset(-8)
        }
        copyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func didTapCopy() {
        let account = [card.account.text?.text, card.account.additionalText?.text]
            .compactMap { $0 }
            .joined(separator: " ")
        guard account.isNotEmpty else { return }
        UIPasteboard.general.string = account
        ToastManager.shared.show(message: Strings.BossStoreDetail.Info.copyToast)
        // 복사 자체는 클라이언트 처리이므로 서버 액션이 있으면 클릭 로그 전송용으로만 전달한다.
        if let action = card.copyButton.storeSectionAction {
            onAction(action)
        } else if let clickLog = card.copyButton.clickLog {
            onAction(.custom(.init(actionType: .unknown), clickLog: clickLog))
        }
    }
}

/// 사장님 가게 메뉴 목록 카드 (이미지 + 메뉴명/가격).
private final class StoreInfoMenuListCardView: UIView {
    init(card: MenuListCard, onAction: @escaping (StoreSectionAction) -> Void) {
        super.init(frame: .zero)
        layer.cornerRadius = 12
        setSDSurfaceStyle(card.style)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        addSubViews([stack])
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }
        card.items.forEach { stack.addArrangedSubview(makeItemRow($0)) }

        // 서버 액션이 없는 더보기 버튼은 표시하지 않는다. (모든 메뉴를 이미 노출)
        if let moreButton = card.moreButton, let action = moreButton.storeSectionAction {
            let button = UIButton(type: .system)
            button.setSDButton(moreButton)
            button.addAction(UIAction { _ in onAction(action) }, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeItemRow(_ item: ImageMenuItem) -> UIView {
        let view = UIView()
        let primaryLabel = StoreSectionTextLabel(font: Fonts.semiBold.font(size: 14))
        primaryLabel.setSDText(item.primaryText)
        let secondaryLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 13))
        secondaryLabel.setSDText(item.secondaryText)

        if let image = item.image {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 8
            imageView.clipsToBounds = true
            imageView.setImage(urlString: image.url)
            view.addSubViews([imageView, primaryLabel, secondaryLabel])
            imageView.snp.makeConstraints {
                $0.top.bottom.leading.equalToSuperview()
                $0.size.equalTo(48)
            }
            primaryLabel.snp.makeConstraints {
                $0.top.equalTo(imageView)
                $0.leading.equalTo(imageView.snp.trailing).offset(10)
                $0.trailing.lessThanOrEqualToSuperview()
            }
            secondaryLabel.snp.makeConstraints {
                $0.top.equalTo(primaryLabel.snp.bottom).offset(2)
                $0.leading.equalTo(primaryLabel)
                $0.trailing.lessThanOrEqualToSuperview()
            }
        } else {
            view.addSubViews([primaryLabel, secondaryLabel])
            primaryLabel.snp.makeConstraints { $0.top.leading.equalToSuperview() }
            secondaryLabel.snp.makeConstraints {
                $0.top.equalTo(primaryLabel.snp.bottom).offset(2)
                $0.leading.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.trailing.lessThanOrEqualToSuperview()
            }
        }
        return view
    }
}
