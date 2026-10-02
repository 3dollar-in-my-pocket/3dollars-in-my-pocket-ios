import UIKit

import Common
import DesignSystem
import Model

final class MenuFormContentView: BaseView {
    let tabView: MenuCategoryTabView
    let categoryView = MenuCategoryView()

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
        stackView.addArrangedSubview(tabView)
        stackView.addArrangedSubview(categoryView)
        stackView.addArrangedSubview(menuStackView)
    }

    override func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func bind(categories: [StoreFoodCategoryResponse], selectedIndex: Int) {
        tabView.bind(categories: categories, selectedIndex: selectedIndex)
        if let category = categories[safe: selectedIndex] {
            categoryView.bind(category: category)
        }
    }

    func reloadMenus(_ viewModels: [MenuInputViewModel]) {
        menuStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        viewModels.forEach(appendMenu)
    }

    func appendMenu(_ viewModel: MenuInputViewModel) {
        menuStackView.addArrangedSubview(MenuInputView(viewModel: viewModel))
    }
}
