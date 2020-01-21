import UIKit

class CategoryChildVC: BaseVC {
    
    var viewModel = CategoryChildViewModel()
    var category: StoreCategory!
    var latitude: Double!
    var longitude: Double!
    
    private lazy var categoryChildView = CategoryChildView.init(category: self.category)
    
    static func instance(category: StoreCategory, latitude: Double, longitude: Double) -> CategoryChildVC {
        return CategoryChildVC.init(nibName: nil, bundle: nil).then {
            $0.category = category
            $0.latitude = latitude
            $0.longitude = longitude
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = categoryChildView
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getStoreByDistance()
    }
    
    private func setupTableView() {
        categoryChildView.tableView.delegate = self
        categoryChildView.tableView.dataSource = self
        categoryChildView.tableView.register(CategoryListCell.self, forCellReuseIdentifier: CategoryListCell.registerId)
    }
    
    private func getStoreByDistance() {
        CategoryService.getStroeByDistance(category: category, latitude: latitude, longitude: longitude) { [weak self] (response) in
            switch response.result {
            case .success(let category):
                self?.viewModel.storeByDistance = category
                self?.categoryChildView.tableView.reloadData()
            case .failure(let error):
                if let vc = self {
                    AlertUtils.show(controller: vc, title: "get store by distance", message: error.localizedDescription)
                }
            }
        }
    }
}

extension CategoryChildVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getDistanceRow(section: section)
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
        
        if let storeCard = self.viewModel.getDistanceStore(indexPath: indexPath) {
            cell.bind(storeCard: storeCard)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        delegate?.onTapBack()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.viewModel.isValidDistanceSection(section: section) {
            return CategoryListHeaderView()
        } else {
            return nil
        }
    }
}



