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

        /// 바는 superview 하단(= safe area 바깥)까지 깔리고 버튼만 safe area 위에 놓이므로,
        /// 실제로 컨텐츠를 가리는 높이는 contentHeight 보다 safe area 하단만큼 더 크다.
        static func coveringHeight(safeAreaBottom: CGFloat) -> CGFloat {
            contentHeight + safeAreaBottom
        }

        /// 바에 가려지지 않도록 컬렉션뷰에 넣어야 할 contentInset.bottom.
        ///
        /// 호스트마다 스크롤뷰의 safe area 보정 적용 여부가 다르다.
        /// 전체화면 호스트는 `contentInsetAdjustmentBehavior` 가 `.automatic` 이라 safe area 가 자동으로 더해지지만,
        /// 홈 바텀시트는 FloatingPanel 이 tracking scrollView 를 `.never` 로 바꾸고
        /// contentInset 을 자기 값(safe area 하단)으로 덮어쓴다.
        /// 그래서 이미 적용된 보정을 빼고 모자란 만큼만 직접 넣는다.
        static func bottomContentInset(coveringHeight: CGFloat, appliedAdjustment: CGFloat) -> CGFloat {
            max(0, coveringHeight - appliedAdjustment)
        }
    }

    /// 실제로 컨텐츠를 가리는 높이. 레이아웃 이후에 읽어야 safe area 가 반영된다.
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
