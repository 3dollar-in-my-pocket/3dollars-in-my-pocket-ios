import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreTabCell: BaseCollectionViewCell, StickyCell {
    enum Layout {
        static let height: CGFloat = 48
        static let horizontalMargin: CGFloat = 16
    }

    var onAction: ((StoreSectionAction) -> Void)?

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        return stackView
    }()

    private let bottomBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray20.color
        return view
    }()

    private var tabs: [SDActionBar] = []
    private var selectedIndex = 0

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabs = []
        selectedIndex = 0
        onAction = nil
    }

    override func setup() {
        contentView.backgroundColor = Colors.systemWhite.color
        contentView.addSubview(stackView)
        contentView.addSubview(bottomBorderView)
    }

    override func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Layout.horizontalMargin)
            $0.height.equalTo(Layout.height)
        }
        bottomBorderView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func bind(_ section: StoreTabSection) {
        tabs = section.tabs
        if selectedIndex >= tabs.count {
            selectedIndex = 0
        }

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, tab) in tabs.enumerated() {
            let itemView = StoreTabItemView(text: tab.button.text)
            itemView.setSelected(index == selectedIndex)
            itemView.addAction(UIAction { [weak self] _ in
                self?.didTapTab(index)
            }, for: .touchUpInside)
            stackView.addArrangedSubview(itemView)
        }
    }

    private func didTapTab(_ index: Int) {
        guard let tab = tabs[safe: index] else { return }

        if selectedIndex != index {
            selectedIndex = index
            for (itemIndex, itemView) in stackView.arrangedSubviews.enumerated() {
                (itemView as? StoreTabItemView)?.setSelected(itemIndex == index)
            }
        }

        if let action = tab.storeSectionAction {
            onAction?(action)
        }
    }
}

private final class StoreTabItemView: UIControl {
    private let label = UILabel()

    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray100.color
        view.isHidden = true
        return view
    }()

    init(text: SDText?) {
        super.init(frame: .zero)

        label.setSDText(text)
        label.isUserInteractionEnabled = false

        addSubview(label)
        addSubview(indicatorView)

        label.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        indicatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ isSelected: Bool) {
        indicatorView.isHidden = isSelected.isNot
        applyTextStyle(isSelected: isSelected)
    }

    private func applyTextStyle(isSelected: Bool) {
        let font = isSelected ? Fonts.bold.font(size: 16) : Fonts.regular.font(size: 16)
        let color = isSelected ? Colors.gray100.color : Colors.gray60.color

        if let attributedText = label.attributedText, attributedText.length > 0 {
            let mutable = NSMutableAttributedString(attributedString: attributedText)
            mutable.addAttributes(
                [.font: font, .foregroundColor: color],
                range: NSRange(location: 0, length: mutable.length)
            )
            label.attributedText = mutable
        } else {
            label.font = font
            label.textColor = color
        }
    }
}
