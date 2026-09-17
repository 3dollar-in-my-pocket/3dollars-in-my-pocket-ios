import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class StoreBottomActionBarView: UIView {
    enum Layout {
        static let topInset: CGFloat = 16
        static let bottomInset: CGFloat = 12
        static let horizontalInset: CGFloat = 20
        static let spacing: CGFloat = 4
        static let buttonHeight: CGFloat = 36
        static let contentHeight: CGFloat = topInset + buttonHeight + bottomInset
    }

    var onAction: ((StoreSectionAction) -> Void)?

    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray20.color
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = Layout.spacing
        return stackView
    }()

    private var actions: [StoreSectionAction?] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        bindConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = Colors.systemWhite.color
        addSubViews([borderView, stackView])
    }

    private func bindConstraints() {
        borderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.topInset)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.height.equalTo(Layout.buttonHeight)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-Layout.bottomInset)
        }
    }

    func bind(_ actionBars: [SDActionBar]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        actions = actionBars.map(\.storeSectionAction)

        let buttons = actionBars.enumerated().map { index, actionBar in
            let button = StoreScreenPreviewActionCell.makeButton()
            button.setSDButton(actionBar.button)
            button.addAction(UIAction { [weak self] _ in self?.didTap(index: index) }, for: .touchUpInside)
            return button
        }
        buttons.forEach { stackView.addArrangedSubview($0) }

        buttons.first?.setContentHuggingPriority(.required, for: .horizontal)
        buttons.first?.setContentCompressionResistancePriority(.required, for: .horizontal)
        let fillingButtons = Array(buttons.dropFirst())
        zip(fillingButtons, fillingButtons.dropFirst()).forEach { button, next in
            button.snp.makeConstraints { $0.width.equalTo(next) }
        }
    }

    private func didTap(index: Int) {
        guard let action = actions[safe: index], let action else { return }
        onAction?(action)
    }
}
