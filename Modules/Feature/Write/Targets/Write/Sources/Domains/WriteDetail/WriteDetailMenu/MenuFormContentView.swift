import UIKit

import Common
import DesignSystem
import Model

final class MenuFormContentView: BaseView {
    let tabView: MenuCategoryTabView
    let categoryView = MenuCategoryView()

    private let tabPlaceholderView = UIView()

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
        stackView.addArrangedSubview(tabPlaceholderView)
        stackView.addArrangedSubview(categoryView)
        stackView.addArrangedSubview(menuStackView)
    }

    override func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        tabPlaceholderView.snp.makeConstraints {
            $0.height.equalTo(MenuCategoryTabView.Layout.height)
        }
    }

    func attachStickyTab(to hostView: UIView) {
        tabView.snp.removeConstraints()
        tabView.translatesAutoresizingMaskIntoConstraints = true
        hostView.addSubview(tabView)
    }

    func updateStickyTabFrame(in hostView: UIView, stickyTopY: CGFloat) {
        let placeholderFrame = tabPlaceholderView.convert(tabPlaceholderView.bounds, to: hostView)
        tabView.frame = CGRect(
            x: placeholderFrame.minX,
            y: max(placeholderFrame.minY, stickyTopY),
            width: placeholderFrame.width,
            height: MenuCategoryTabView.Layout.height
        )
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
