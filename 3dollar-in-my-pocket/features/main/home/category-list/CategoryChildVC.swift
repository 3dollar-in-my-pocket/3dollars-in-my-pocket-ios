import UIKit

class CategoryChildVC: BaseVC {
    
    var viewModel = CategoryChildViewModel()
    var category: StoreCategory!
    var latitude: Double!
    var longitude: Double!
    var order = Order.DISTANCE
    
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
    
    override func bindViewModel() {
        categoryChildView.nearOrderBtn.rx.tap.bind { [weak self] (_) in
            if let vc = self,
                !vc.categoryChildView.nearOrderBtn.isSelected {
                vc.order = .DISTANCE
                vc.categoryChildView.nearOrderBtn.isSelected = true
                vc.categoryChildView.reviewOrderBtn.isSelected = false
                vc.getStoreByDistance()
            }
        }.disposed(by: disposeBag)
        
        categoryChildView.reviewOrderBtn.rx.tap.bind { [weak self] (_) in
            if let vc = self,
                !vc.categoryChildView.reviewOrderBtn.isSelected {
                vc.order = .REVIEW
                vc.categoryChildView.nearOrderBtn.isSelected = false
                vc.categoryChildView.reviewOrderBtn.isSelected = true
                vc.getStoreByReview()
            }
        }.disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if categoryChildView.nearOrderBtn.isSelected {
            getStoreByDistance()
        } else {
            getStoreByReview()
        }
    }
    
    private func setupTableView() {
        categoryChildView.tableView.delegate = self
        categoryChildView.tableView.dataSource = self
        categoryChildView.tableView.register(CategoryListCell.self, forCellReuseIdentifier: CategoryListCell.registerId)
    }
    
    private func getStoreByDistance() {
        CategoryService.getStroeByDistance(category: category, latitude: latitude, longitude: longitude) { [weak self] (response) in
            switch response.result {
            case .success(let categoryByDistance):
                self?.viewModel.storeByDistance = categoryByDistance
                self?.categoryChildView.tableView.reloadData()
            case .failure(let error):
                if let vc = self {
                    AlertUtils.show(controller: vc, title: "get store by distance", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func getStoreByReview() {
        CategoryService.getStoreByReview(category: category, latitude: latitude, longitude: longitude) { [weak self] (response) in
            switch response.result {
            case .success(let categoryByReview):
                self?.viewModel.storeByReview = categoryByReview
                self?.categoryChildView.tableView.reloadData()
            case .failure(let error):
                if let vc = self {
                    AlertUtils.show(controller: vc, title: "get store by review", message: error.localizedDescription)
                }
            }
        }
    }
}

extension CategoryChildVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.order {
        case .DISTANCE:
            return self.viewModel.getNumberOfDistanceRow(section: section)
        case .REVIEW:
            return self.viewModel.getNumberOfReviewRow(section: section)
        }
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
        
        switch self.order {
        case .DISTANCE:
            if let storeCard = self.viewModel.getDistanceStore(indexPath: indexPath) {
                cell.bind(order: .DISTANCE, storeCard: storeCard)
            }
        default:
            if let storeCard = self.viewModel.getReviewStore(indexPath: indexPath) {
                cell.bind(order: .REVIEW, storeCard: storeCard)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.order {
        case .DISTANCE:
            if let storeCard = self.viewModel.getDistanceStore(indexPath: indexPath) {
                self.navigationController?.pushViewController(DetailVC.instance(storeId: storeCard.id), animated: true)
            }
        case .REVIEW:
            if let storeCard = self.viewModel.getReviewStore(indexPath: indexPath) {
                self.navigationController?.pushViewController(DetailVC.instance(storeId: storeCard.id), animated: true)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.order {
        case .DISTANCE:
            return self.viewModel.getValidDistanceCount()
        case .REVIEW:
            return self.viewModel.getValidReviewCount()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.order {
        case .DISTANCE:
            if self.viewModel.isValidDistanceSection(section: section) {
                return CategoryListHeaderView().then {
                    $0.setDistanceHeader(section: self.viewModel.getRealDistanceSection(section: section))
                }
            } else {
                return nil
            }
        case .REVIEW:
            if self.viewModel.isValidReviewSection(section: section) {
                return CategoryListHeaderView().then {
                    $0.setReviewHeader(section: self.viewModel.getRealReviewSection(section: section))
                }
            } else {
                return nil
            }
        }
    }
}

public enum Order: String {
    case DISTANCE = "DISTANCE"
    case REVIEW = "REVIEW"
}



