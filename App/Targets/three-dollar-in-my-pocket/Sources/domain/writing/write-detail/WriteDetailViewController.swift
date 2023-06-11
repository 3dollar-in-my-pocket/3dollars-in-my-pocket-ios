import UIKit

import NMapsMap

typealias WriteDetailSanpshot = NSDiffableDataSourceSnapshot<WriteDetailSection, WriteDetailSectionItem>

protocol WriteDetailDelegate: AnyObject {
    func onWriteSuccess(storeId: Int)
}

final class WriteDetailViewController: BaseViewController, WriteDetailCoordinator {
    weak var deleagte: WriteDetailDelegate?
    
    private weak var coordinator: WriteDetailCoordinator?
    private let writeDetailView = WriteDetailView()
    private lazy var dataSource = WriteDetailDataSource(collectionView: writeDetailView.collectionView, viewModel: viewModel)
    private let viewModel: WriteDetailViewModel
    
    init(location: Location, address: String) {
        self.viewModel = WriteDetailViewModel(location: location, address: address)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        //    self.writeDetailView.menuTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    static func instance(location: Location, address: String) -> WriteDetailViewController {
        return WriteDetailViewController(location: location, address: address)
    }
    
    override func viewDidLoad() {
        //    self.setupMenuTableView()
        //    self.setupCategoryCollectionView()
        //    self.setupKeyboardEvent()
        
        super.viewDidLoad()
        view = writeDetailView
        coordinator = self
        
        viewModel.input.viewDidLoad.send(())
        
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
        writeDetailView.backButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { owner, _ in
                owner.coordinator?.pop()
            }
            .store(in: &cancellables)
        
        writeDetailView.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { owner, _ in
                owner.coordinator?.dismiss()
            }
            .store(in: &cancellables)
        
        //    self.writeDetailView.bgTap.rx.event
        //      .subscribe { [weak self] event in
        //        self?.writeDetailView.endEditing(true)
        //      }.disposed(by: disposeBag)
    }
    
    override func bindViewModelInput() {
        writeDetailView.writeButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.tapSave)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.isSaveButtonEnable
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink(receiveValue: { owner, isEnable in
                owner.writeDetailView.setSaveButtonEnable(isEnable: isEnable)
            })
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isShow in
                owner.coordinator?.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                owner.handleRoute(route: route)
            }
            .store(in: &cancellables)
        
        viewModel.output.error
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, error in
                owner.coordinator?.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.sections
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, sections in
                owner.updateDataSource(section: sections)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(route: WriteDetailViewModel.Route) {
        switch route {
        case .pop:
            coordinator?.pop()
            
        case .presentFullMap:
            coordinator?.presentFullMap()
            
        case .presentCategorySelection:
            coordinator?.presentCategorySelection()
            
        case .dismiss:
            coordinator?.dismiss()
        }
    }
    
    private func updateDataSource(section: [WriteDetailSection]) {
        var snapshot = WriteDetailSanpshot()
        
        section.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
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
//  private func setupKeyboardEvent() {
//    NotificationCenter.default.addObserver(self, selector: #selector(onShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//    NotificationCenter.default.addObserver(self, selector: #selector(onHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
