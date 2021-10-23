import UIKit
import RxSwift
import RxCocoa

final class StoreDetailView: BaseView {
  
  private let navigationView = UIView().then {
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.04
    $0.backgroundColor = .white
  }
  
  let backButton = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_back_black"), for: .normal)
  }
  
  let mainCategoryImage = UIImageView()
  
  let deleteRequestButton = UIButton().then {
    $0.setTitle("store_detail_delete_request".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 92, b: 67), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)
  }
  
  private let scrollView = UIScrollView()
  
  private let containerView = UIView()
  
  fileprivate let storeOverview = StoreOverview()
  
  fileprivate let storeInfoView = StoreInfoView()
  
  let tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.tableFooterView = UIView()
    $0.rowHeight = UITableView.automaticDimension
    $0.backgroundColor = .clear
    $0.separatorStyle = .none
    $0.sectionHeaderHeight = UITableView.automaticDimension
    $0.estimatedSectionHeaderHeight = 1
    $0.sectionFooterHeight = .leastNonzeroMagnitude
    $0.contentInsetAdjustmentBehavior = .never
    $0.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: 1, height: 1))
    $0.contentInset = .init(top: -1, left: 0, bottom: 0, right: 0)
    $0.showsVerticalScrollIndicator = false
  }
  
  
  override func setup() {
    self.containerView.addSubViews([
      self.storeOverview,
      self.storeInfoView
    ])
    
    self.scrollView.addSubview(self.containerView)
    
    self.addSubViews([
      self.scrollView,
      self.navigationView,
      self.backButton,
      self.mainCategoryImage,
      self.deleteRequestButton
    ])
    self.backgroundColor = UIColor(r: 250, g: 250, b: 250)
  }
  
  override func bindConstraints() {
    self.navigationView.snp.makeConstraints { (make) in
      make.left.right.top.equalToSuperview()
      make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).offset(60)
    }
    
    self.backButton.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.centerY.equalTo(self.mainCategoryImage)
    }
    
    self.mainCategoryImage.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.width.height.equalTo(60)
      make.bottom.equalTo(self.navigationView).offset(-3)
    }
    
    self.deleteRequestButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.mainCategoryImage)
      make.right.equalToSuperview().offset(-24)
    }
    
    self.scrollView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.bottom.equalTo(safeAreaLayoutGuide)
      make.top.equalTo(self.navigationView.snp.bottom).offset(-20)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.edges.equalTo(self.scrollView)
      make.width.equalTo(UIScreen.main.bounds.width)
      make.top.equalTo(self.storeOverview)
      make.bottom.equalTo(self.storeInfoView)
    }
    
    self.storeOverview.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview()
      make.right.equalToSuperview()
    }
    
    self.storeInfoView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalTo(self.storeOverview.snp.bottom)
    }
    
//    self.tableView.snp.makeConstraints { make in
//      make.left.right.equalToSuperview()
//      make.bottom.equalTo(safeAreaLayoutGuide)
//      make.top.equalTo(self.navigationView.snp.bottom).offset(-20)
//    }
  }
  
  func bind(category: StoreCategory) {
    self.mainCategoryImage.image = UIImage(named: "img_60_\(category.lowcase)")
  }
}

extension Reactive where Base: StoreDetailView {
  var store: Binder<Store> {
    return Binder(self.base) { view, store in
      view.bind(category: store.categories[0])
      view.storeOverview.bind(store: store)
      view.storeInfoView.bind(store: store)
    }
  }
}
