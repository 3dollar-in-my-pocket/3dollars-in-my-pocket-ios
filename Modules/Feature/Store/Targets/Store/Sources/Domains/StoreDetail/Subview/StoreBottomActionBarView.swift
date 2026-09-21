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

        static func coveringHeight(safeAreaBottom: CGFloat) -> CGFloat {
            contentHeight + safeAreaBottom
        }

        static func bottomContentInset(coveringHeight: CGFloat, appliedAdjustment: CGFloat) -> CGFloat {
            max(0, coveringHeight - appliedAdjustment)
        }
    }

    var coveringHeight: CGFloat {
        Layout.coveringHeight(safeAreaBottom: safeAreaInsets.bottom)
    }

    var onAction: ((StoreSectionAction) -> Void)?

    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray20.color
        return view
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: Layout.horizontalInset,
            bottom: 0,
            right: Layout.horizontalInset
        )
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
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
        addSubViews([borderView, scrollView])
        scrollView.addSubview(stackView)
    }

    private func bindConstraints() {
        borderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.topInset)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.buttonHeight)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-Layout.bottomInset)
        }
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
    }

    func bind(_ actionBars: [SDActionBar]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        actions = actionBars.map(\.storeSectionAction)

        actionBars.enumerated().forEach { index, actionBar in
            let button = makeButton()
            button.setSDButton(actionBar.button)
            button.addAction(UIAction { [weak self] _ in self?.didTap(index: index) }, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        scrollView.setContentOffset(CGPoint(x: -Layout.horizontalInset, y: 0), animated: false)
    }

    private func makeButton() -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = Layout.buttonHeight / 2
        button.clipsToBounds = true
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        let halfSpacing = Layout.spacing / 2
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12 + halfSpacing, bottom: 8, right: 12 + halfSpacing)
        button.snp.makeConstraints { $0.height.equalTo(Layout.buttonHeight) }
        return button
    }

    private func didTap(index: Int) {
        guard let action = actions[safe: index], let action else { return }
        onAction?(action)
    }
}
