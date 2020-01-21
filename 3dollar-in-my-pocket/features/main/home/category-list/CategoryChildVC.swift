import UIKit

class CategoryChildVC: BaseVC {
    
    var category: StoreCategory!
    
    private lazy var categoryChildView = CategoryChildView.init(category: self.category)
    
    static func instance(category: StoreCategory) -> CategoryChildVC {
        return CategoryChildVC.init(nibName: nil, bundle: nil).then {
            $0.category = category
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = categoryChildView
        setupTableView()
    }
    
    private func setupTableView() {
        categoryChildView.tableView.delegate = self
        categoryChildView.tableView.dataSource = self
        categoryChildView.tableView.register(CategoryListCell.self, forCellReuseIdentifier: CategoryListCell.registerId)
    }
}

extension CategoryChildVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryListCell.registerId, for: indexPath) as? CategoryListCell else {
            return BaseTableViewCell()
        }
        
        cell.setBottomRadius(isLast: tableView.numberOfRows(inSection: indexPath.section) - 1 == indexPath.row)
        if indexPath.row % 2 == 0 {
            cell.setEvenBg()
        } else {
            cell.setOddBg()
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        delegate?.onTapBack()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return CategoryListHeaderView()
    }
}

