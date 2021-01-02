import UIKit

protocol CategoryChildDelegate {
  
  func setMarkers(storeCards: [StoreCard])
}

class CategoryChildVC: BaseVC {
  
  var viewModel = CategoryChildViewModel()
  var delegate: CategoryChildDelegate?
  var category: StoreCategory!
  var latitude: Double!
  var longitude: Double!
  var order = Order.DISTANCE
  
  private lazy var categoryChildView = CategoryChildView.init(category: self.category)
  
  static func instance(
    category: StoreCategory,
    latitude: Double,
    longitude: Double
  ) -> CategoryChildVC {
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let categoryListVC = self.parent?.parent as? CategoryListVC,
       let currentPosition = categoryListVC.currentPosition {
      
      if categoryChildView.nearOrderBtn.isSelected {
        getStoreByDistance(mapLatitude: currentPosition.latitude, mapLongitude: currentPosition.longitude)
      } else {
        getStoreByReview(mapLatitude: currentPosition.latitude, mapLongitude: currentPosition.longitude)
      }
    } else {
      if categoryChildView.nearOrderBtn.isSelected {
        getStoreByDistance(mapLatitude: nil, mapLongitude: nil)
      } else {
        getStoreByReview(mapLatitude: nil, mapLongitude: nil)
      }
    }
  }
  
  override func bindEvent() {
    categoryChildView.nearOrderBtn.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .order_by_distance_button_list, page: .store_list_page)
      })
      .bind { [weak self] (_) in
      if let vc = self,
         !vc.categoryChildView.nearOrderBtn.isSelected {
        vc.order = .DISTANCE
        vc.categoryChildView.nearOrderBtn.isSelected = true
        vc.categoryChildView.reviewOrderBtn.isSelected = false
        
        let cameraPosition = (vc.parent?.parent as? CategoryListVC)?.currentPosition
        vc.getStoreByDistance(mapLatitude: cameraPosition?.latitude, mapLongitude: cameraPosition?.longitude)
      }
    }.disposed(by: disposeBag)
    
    categoryChildView.reviewOrderBtn.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .order_by_rating_button_list, page: .store_list_page)
      })
      .bind { [weak self] (_) in
      if let vc = self,
         !vc.categoryChildView.reviewOrderBtn.isSelected {
        vc.order = .REVIEW
        vc.categoryChildView.nearOrderBtn.isSelected = false
        vc.categoryChildView.reviewOrderBtn.isSelected = true
        
        let cameraPosition = (vc.parent?.parent as? CategoryListVC)?.currentPosition
        vc.getStoreByReview(mapLatitude: cameraPosition?.latitude, mapLongitude: cameraPosition?.longitude)
      }
    }.disposed(by: disposeBag)
  }
  
  private func setupTableView() {
    categoryChildView.tableView.delegate = self
    categoryChildView.tableView.dataSource = self
    categoryChildView.tableView.register(
      CategoryListCell.self,
      forCellReuseIdentifier: CategoryListCell.registerId
    )
  }
  
  private func getStoreByDistance(mapLatitude: Double?, mapLongitude: Double?) {
    CategoryService().getStoreByDistance(
      category: category,
      latitude: latitude,
      longitude: longitude,
      mapLatitude: mapLatitude,
      mapLongitude: mapLongitude
    )
    .subscribe(
      onNext: { [weak self] categoryByDistance in
        guard let self = self else { return }
        
        self.viewModel.setDistance(storeByDistance: categoryByDistance)
        self.categoryChildView.setEmpty(isEmpty: self.viewModel.isDistanceEmpty())
        self.delegate?.setMarkers(storeCards: self.viewModel.getAllDistanceStores())
        self.categoryChildView.tableView.reloadData()
      },
      onError: { [weak self] error in
        guard let self = self else { return }
        if let httpError = error as? HTTPError {
          self.showHTTPErrorAlert(error: httpError)
        } else if let error = error as? CommonError {
          let alertContent = AlertContent(title: nil, message: error.description)
          
          self.showSystemAlert(alert: alertContent)
        }
      }
    )
    .disposed(by: disposeBag)
  }
  
  private func getStoreByReview(mapLatitude: Double?, mapLongitude: Double?) {
    CategoryService().getStoreByReview(
      category: category,
      latitude: latitude,
      longitude: longitude,
      mapLatitude: mapLatitude,
      mapLongitude: mapLongitude
    )
    .subscribe(
      onNext: { [weak self] categoryByReview in
        guard let self = self else { return }
        
        self.viewModel.setReview(storeByReview: categoryByReview)
        self.categoryChildView.setEmpty(isEmpty: self.viewModel.isReviewEmpty())
        self.delegate?.setMarkers(storeCards: self.viewModel.getAllReviewStores())
        self.categoryChildView.tableView.reloadData()
      },
      onError: { [weak self] error in
        guard let self = self else { return }
        if let httpError = error as? HTTPError {
          self.showHTTPErrorAlert(error: httpError)
        } else if let error = error as? CommonError {
          let alertContent = AlertContent(title: nil, message: error.description)
          
          self.showSystemAlert(alert: alertContent)
        }
      }
    ).disposed(by: disposeBag)
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
        GA.shared.logEvent(event: .store_list_item_clicked, page: .store_list_page)
        self.navigationController?.pushViewController(DetailVC.instance(storeId: storeCard.id), animated: true)
      }
    case .REVIEW:
      if let storeCard = self.viewModel.getReviewStore(indexPath: indexPath) {
        GA.shared.logEvent(event: .store_list_item_clicked, page: .store_list_page)
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
          $0.setDistanceHeader(section: self.viewModel.storeByDistance.indexList[section])
        }
      } else {
        return nil
      }
    case .REVIEW:
      if self.viewModel.isValidReviewSection(section: section) {
        return CategoryListHeaderView().then {
          $0.setReviewHeader(section: self.viewModel.storeByReview.indexList[section])
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
