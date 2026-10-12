import UIKit

import Common
import DesignSystem
import Model

final class MenuFormContentView: BaseView {
    let tabView: MenuCategoryTabView
    let categoryView = MenuCategoryView()

    private let stickyHeaderPlaceholderView = UIView()

    private let stickyHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        return view
    }()

    private let stickyHeaderBottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray20.color
        view.isHidden = true
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private let menuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private var stickyHeaderHeight: CGFloat {
        MenuCategoryTabView.Layout.height + MenuCategoryView.Layout.height
    }

    init(showsFilterButton: Bool) {
        self.tabView = MenuCategoryTabView(showsFilterButton: showsFilterButton)
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        backgroundColor = Colors.systemWhite.color
        addSubview(stackView)
        stackView.addArrangedSubview(stickyHeaderPlaceholderView)
        stackView.addArrangedSubview(menuStackView)

        stickyHeaderView.addSubViews([
            tabView,
            categoryView,
            stickyHeaderBottomLineView
        ])
    }

    override func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stickyHeaderPlaceholderView.snp.makeConstraints {
            $0.height.equalTo(stickyHeaderHeight)
        }

        tabView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        categoryView.snp.makeConstraints {
            $0.top.equalTo(tabView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        stickyHeaderBottomLineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func attachStickyHeader(to hostView: UIView) {
        hostView.addSubview(stickyHeaderView)
    }

    func updateStickyHeaderFrame(in hostView: UIView, stickyTopY: CGFloat) {
        let placeholderFrame = stickyHeaderPlaceholderView.convert(stickyHeaderPlaceholderView.bounds, to: hostView)
        stickyHeaderView.frame = CGRect(
            x: placeholderFrame.minX,
            y: max(placeholderFrame.minY, stickyTopY),
            width: placeholderFrame.width,
            height: stickyHeaderHeight
        )
        stickyHeaderBottomLineView.isHidden = placeholderFrame.minY >= stickyTopY
    }

    @discardableResult
    func appendMenuView(_ viewModel: MenuInputViewModel) -> UIView {
        let menuView = MenuInputView(viewModel: viewModel)
        menuStackView.addArrangedSubview(menuView)
        return menuView
    }

    func bind(categories: [StoreFoodCategoryResponse], selectedIndex: Int) {
        tabView.bind(categories: categories, selectedIndex: selectedIndex)
        if let category = categories[safe: selectedIndex] {
            categoryView.bind(category: category)
        }
    }

    func reloadMenus(_ viewModels: [MenuInputViewModel]) {
        menuStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        viewModels.forEach { appendMenuView($0) }
    }
}
