import UIKit
import Combine

import Common
import DesignSystem
import Model

import SnapKit

final class HomeBottomSheetTabView: BaseView {
    enum Layout {
        static let height: CGFloat = 48
        static let contentInset: CGFloat = 4
        static let topInset: CGFloat = 12
        static let bottomInset: CGFloat = 8
        static let horizontalInset: CGFloat = 16
        static let containerHeight: CGFloat = topInset + height + bottomInset
    }

    let didTapTab = PassthroughSubject<Int, Never>()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()

    override func setup() {
        backgroundColor = Colors.gray10.color
        layer.cornerRadius = Layout.height / 2
        layer.masksToBounds = true
        addSubview(stackView)
    }

    override func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Layout.contentInset)
        }

        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }

    func bind(_ tabs: [HomeBottomSheetTabItem]) {
        if stackView.arrangedSubviews.count != tabs.count {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            for index in tabs.indices {
                let itemView = TabItemView()
                itemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapItem(_:))))
                itemView.tag = index
                stackView.addArrangedSubview(itemView)
            }
        }

        for (index, tab) in tabs.enumerated() {
            (stackView.arrangedSubviews[safe: index] as? TabItemView)?.bind(tab)
        }
    }

    @objc private func didTapItem(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        didTapTab.send(index)
    }
}

private final class TabItemView: BaseView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 16)
        label.textColor = Colors.gray60.color
        label.textAlignment = .center
        return label
    }()

    override func setup() {
        layer.cornerRadius = (HomeBottomSheetTabView.Layout.height - HomeBottomSheetTabView.Layout.contentInset * 2) / 2
        layer.masksToBounds = true
        isAccessibilityElement = true
        addSubview(titleLabel)
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(8)
            $0.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
    }

    func bind(_ item: HomeBottomSheetTabItem) {
        let state = item.isSelected ? item.tab.selected : item.tab.unselected
        titleLabel.setSDText(state.title, customFont: Fonts.regular.font(size: 16))
        layer.borderWidth = 0
        layer.borderColor = nil
        backgroundColor = .clear
        setSDSurfaceStyle(state.style)
        accessibilityLabel = titleLabel.text
        accessibilityTraits = item.isSelected ? [.button, .selected] : .button
    }
}
