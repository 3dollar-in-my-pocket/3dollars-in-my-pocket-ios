import UIKit

import NMapsMap
import RxSwift
import RxDataSources

typealias WriteDetailSanpshot = NSDiffableDataSourceSnapshot<WriteDetailSection, WriteDetailSectionItem>

protocol WriteDetailDelegate: class {
  func onWriteSuccess(storeId: Int)
}

final class WriteDetailViewController: BaseViewController {
    
    weak var deleagte: WriteDetailDelegate?
    
    private let writeDetailView = WriteDetailView()
    private lazy var dataSource = WriteDetailDataSource(collectionView: writeDetailView.collectionView)
    
    let viewModel: WriteDetailViewModel
    var menuDataSource: RxTableViewSectionedReloadDataSource<MenuSection>!
    
    init(address: String, location: (Double, Double)) {
        self.viewModel = WriteDetailViewModel(
            address: address,
            location: location,
            storeService: StoreService(),
            globalState: GlobalState.shared
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        //    self.writeDetailView.menuTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func instance(
        address: String,
        location: (Double, Double)
    ) -> WriteDetailViewController {
        return WriteDetailViewController(address: address, location: location)
    }
    
    override func viewDidLoad() {
        //    self.setupMenuTableView()
        //    self.setupCategoryCollectionView()
        //    self.setupKeyboardEvent()
        
        super.viewDidLoad()
        view = writeDetailView
        
        var snapshot = WriteDetailSanpshot()
        
        let locationSection = WriteDetailSection(type: .location, items: [.location])
        let nameSection = WriteDetailSection(type: .name, items: [.name])
        let storeTypeSection = WriteDetailSection(type: .storeType, items: [.storeType])
        let paymentSection = WriteDetailSection(type: .payment, items: [.payment])
        let sections = [
            locationSection,
            nameSection,
            storeTypeSection,
            paymentSection
        ]
        
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        
        dataSource.apply(
            snapshot,
            animatingDifferences: true
        )
        
        //    self.writeDetailView.scrollView.delegate = self
        //    self.viewModel.fetchInitialData()
        //    self.addObservers()
    }
    
    //  override func observeValue(
    //    forKeyPath keyPath: String?,
    //    of object: Any?,
    //    change: [NSKeyValueChangeKey : Any]?,
    //    context: UnsafeMutableRawPointer?
    //  ) {
    //    if let obj = object as? UITableView {
    //      if obj == self.writeDetailView.menuTableView && keyPath == "contentSize" {
    //        self.writeDetailView.refreshMenuTableViewHeight()
    //      }
    //    }
    //  }
    
    override func bindEvent() {
        //    self.writeDetailView.bgTap.rx.event
        //      .subscribe { [weak self] event in
        //        self?.writeDetailView.endEditing(true)
        //      }.disposed(by: disposeBag)
        //
        //    self.writeDetailView.backButton.rx.tap
        //      .observeOn(MainScheduler.instance)
        //      .bind(onNext: self.popupVC)
        //      .disposed(by: disposeBag)
        //
        //    self.writeDetailView.modifyLocationButton.rx.tap
        //      .observeOn(MainScheduler.instance)
        //      .bind(onNext: self.popupVC)
        //      .disposed(by: disposeBag)
    }
}
  
//  private func addObservers() {
//    self.writeDetailView.menuTableView.addObserver(
//      self,
//      forKeyPath: "contentSize",
//      options: .new,
//      context: nil
//    )
//  }
//
//  private func popupVC() {
//    self.navigationController?.popViewController(animated: true)
//  }
//
//  private func isValid(category: StreetFoodStoreCategory?, storeName: String) -> Bool {
//    return category != nil && !storeName.isEmpty
//  }
//
//  private func setupCategoryCollectionView() {
//    self.writeDetailView.categoryCollectionView.register(
//      WriteCategoryCell.self,
//      forCellWithReuseIdentifier: WriteCategoryCell.registerId
//    )
//    self.writeDetailView.categoryCollectionView.rx
//      .setDelegate(self)
//      .disposed(by: disposeBag)
//    self.writeDetailView.categoryCollectionView.rx.itemSelected
//      .bind { [weak self] indexPath in
//        guard let self = self else { return }
//        if indexPath.row == 0 {
//          self.viewModel.input.tapAddCategory.onNext(())
//        } else {
//          self.viewModel.input.deleteCategory.onNext(indexPath.row - 1)
//        }
//      }
//      .disposed(by: disposeBag)
//  }
//
//  private func setupMenuTableView() {
//    self.writeDetailView.menuTableView.register(
//      MenuCell.self,
//      forCellReuseIdentifier: MenuCell.registerId
//    )
//    self.writeDetailView.menuTableView.rx
//      .setDelegate(self)
//      .disposed(by: disposeBag)
//    self.menuDataSource = RxTableViewSectionedReloadDataSource<MenuSection> { (dataSource, tableView, indexPath, item) in
//      guard let cell = tableView.dequeueReusableCell(
//        withIdentifier: MenuCell.registerId,
//        for: indexPath
//      ) as? MenuCell else { return BaseTableViewCell() }
//
//      cell.setMenu(menu: item)
//      cell.nameField.rx.controlEvent(.editingDidEnd)
//        .withLatestFrom(cell.nameField.rx.text.orEmpty)
//        .map { (indexPath, $0) }
//        .bind(to: self.viewModel.input.menuName)
//        .disposed(by: cell.disposeBag)
//
//      cell.descField.rx.controlEvent(.editingDidEnd)
//        .withLatestFrom(cell.descField.rx.text.orEmpty)
//        .map { (indexPath, $0) }
//        .bind(to: self.viewModel.input.menuPrice)
//        .disposed(by: cell.disposeBag)
//
//      return cell
//    }
//  }
//
//  private func setupKeyboardEvent() {
//    NotificationCenter.default.addObserver(self, selector: #selector(onShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//    NotificationCenter.default.addObserver(self, selector: #selector(onHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//  }
//
//  private func showCategoryDialog(selectedCategories: [StreetFoodStoreCategory?]) {
//    let addCategoryVC = AddCategoryVC.instance(selectedCategory: selectedCategories).then {
//      $0.delegate = self
//    }
//
//    self.writeDetailView.showDim(isShow: true)
//    self.present(addCategoryVC, animated: true, completion: nil)
//  }
//
//  private func dismissAndGoDetail(storeId: Int) {
//    self.dismiss(animated: true, completion: nil)
//    self.deleagte?.onWriteSuccess(storeId: storeId)
//  }
//
//  @objc func onShowKeyboard(notification: NSNotification) {
//    let userInfo = notification.userInfo!
//    var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//    keyboardFrame = self.view.convert(keyboardFrame, from: nil)
//
//    var contentInset:UIEdgeInsets = self.writeDetailView.scrollView.contentInset
//    contentInset.bottom = keyboardFrame.size.height + 50
//    self.writeDetailView.scrollView.contentInset = contentInset
//  }
//
//  @objc func onHideKeyboard(notification: NSNotification) {
//    let contentInset:UIEdgeInsets = UIEdgeInsets.zero
//
//    self.writeDetailView.scrollView.contentInset = contentInset
//  }
//}
//
//extension WriteDetailVC: UIScrollViewDelegate {
//
//  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//    self.writeDetailView.endEditing(true)
//    self.writeDetailView.hideRegisterButton()
//  }
//
//  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//    if !decelerate {
//      self.writeDetailView.showRegisterButton()
//    }
//  }
//
//  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//    self.writeDetailView.showRegisterButton()
//  }
//}
//
//extension WriteDetailVC: AddCategoryDelegate {
//
//  func onDismiss() {
//    self.writeDetailView.showDim(isShow: false)
//  }
//
//  func onSuccess(selectedCategories: [StreetFoodStoreCategory]) {
//    self.viewModel.input.addCategories.onNext(selectedCategories)
//    self.writeDetailView.showDim(isShow: false)
//  }
//}
//
//extension WriteDetailVC: UITableViewDelegate {
//  func tableView(
//    _ tableView: UITableView,
//    viewForHeaderInSection section: Int
//  ) -> UIView? {
//    let menuHeaderView = MenuHeaderView().then {
//      $0.frame = CGRect(
//        x: 0,
//        y: 0,
//        width: tableView.frame.width,
//        height: 56
//      )
//    }
//    let sectionCategory = self.menuDataSource.sectionModels[section].category ?? .BUNGEOPPANG
//
//    menuHeaderView.bind(category: sectionCategory)
//    menuHeaderView.deleteButton.rx.tap
//      .map { section }
//      .subscribe(onNext: (self.viewModel.input.deleteCategory.onNext))
//      .disposed(by: menuHeaderView.disposeBag)
//
//    return menuHeaderView
//  }
//
//  func tableView(
//    _ tableView: UITableView,
//    heightForFooterInSection section: Int
//  ) -> CGFloat {
//    return 20
//  }
//
//  func tableView(
//    _ tableView: UITableView,
//    viewForFooterInSection section: Int
//  ) -> UIView? {
//    return MenuFooterView(frame: CGRect(
//      x: 0,
//      y: 0,
//      width: tableView.frame.width,
//      height: 20
//    ))
//  }
//}

