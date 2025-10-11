//import UIKit
//
//import NMapsMap
//import Common
//import DesignSystem
//import Model
//import Log
//
//typealias WriteDetailSanpshot = NSDiffableDataSourceSnapshot<WriteDetailSection, WriteDetailSectionItem>
//
//protocol WriteDetailDelegate: AnyObject {
//    func onSuccessWrite(storeId: Int)
//    
//    func onSuccessEdit(storeCreateResponse: UserStoreCreateResponse)
//}
//
//final class WriteDetailViewController: BaseViewController {
//    override var screenName: ScreenName {
//        return viewModel.output.screenName
//    }
//    
//    weak var deleagte: WriteDetailDelegate?
//    
//    var onSuccessWrite: ((Int) -> Void)?
//    var onSuccessEdit: ((UserStoreCreateResponse) -> Void)?
//    
//    private let writeDetailView = WriteDetailView()
//    private lazy var dataSource = WriteDetailDataSource(collectionView: writeDetailView.collectionView, viewModel: viewModel)
//    private let viewModel: WriteDetailViewModel
//    
//    init(viewModel: WriteDetailViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view = writeDetailView
//        observeKeyboardEvent()
//        viewModel.input.viewDidLoad.send(())
//    }
//    
//    override func bindEvent() {
//        writeDetailView.backButton
//            .controlPublisher(for: .touchUpInside)
//            .withUnretained(self)
//            .sink { owner, _ in
//                owner.navigationController?.popViewController(animated: true)
//            }
//            .store(in: &cancellables)
//    }
//    
//    override func bindViewModelInput() {
//        writeDetailView.writeButton
//            .controlPublisher(for: .touchUpInside)
//            .mapVoid
//            .subscribe(viewModel.input.tapSave)
//            .store(in: &cancellables)
//        
//        writeDetailView.closeButton
//            .controlPublisher(for: .touchUpInside)
//            .mapVoid
//            .subscribe(viewModel.input.didTapClose)
//            .store(in: &cancellables)
//    }
//    
//    override func bindViewModelOutput() {
//        viewModel.output.isCloseButtonHidden
//            .main
//            .assign(to: \.isHidden, on: writeDetailView.closeButton)
//            .store(in: &cancellables)
//        
//        viewModel.output.isSaveButtonEnable
//            .receive(on: DispatchQueue.main)
//            .withUnretained(self)
//            .sink(receiveValue: { owner, isEnable in
//                owner.writeDetailView.setSaveButtonEnable(isEnable: isEnable)
//            })
//            .store(in: &cancellables)
//        
//        viewModel.output.showLoading
//            .receive(on: DispatchQueue.main)
//            .withUnretained(self)
//            .sink { owner, isShow in
//                DesignSystem.LoadingManager.shared.showLoading(isShow: isShow)
//            }
//            .store(in: &cancellables)
//        
//        viewModel.output.route
//            .receive(on: DispatchQueue.main)
//            .withUnretained(self)
//            .sink { owner, route in
//                owner.handleRoute(route: route)
//            }
//            .store(in: &cancellables)
//        
//        viewModel.output.error
//            .receive(on: DispatchQueue.main)
//            .withUnretained(self)
//            .sink { owner, error in
//                owner.showErrorAlert(error: error)
//            }
//            .store(in: &cancellables)
//        
//        viewModel.output.sections
//            .receive(on: DispatchQueue.main)
//            .withUnretained(self)
//            .sink { owner, sections in
//                owner.updateDataSource(section: sections)
//            }
//            .store(in: &cancellables)
//    }
//    
//    private func handleRoute(route: WriteDetailViewModel.Route) {
//        switch route {
//        case .pop:
//            navigationController?.popViewController(animated: true)
//            
//        case .presentMapDetail(let location, let storeName):
//            let location = LocationResponse(latitude: location.latitude, longitude: location.longitude)
//            presentMapDetail(location: location, storeName: storeName)
//            
//        case .presentCategorySelection(let viewModel):
//            presentCategorySelection(viewModel)
//            
//        case .dismissWithStoreId(let storeId):
//            dismiss(animated: true) { [weak self] in
//                self?.onSuccessWrite?(storeId)
//            }
//            
//        case .dismissWithUpdatedStore(let storeCreateResponse):
//            navigationController?.popViewController(animated: true)
//            onSuccessEdit?(storeCreateResponse)
//            
//        case .presentWriteAddress(let viewModel):
//            presentWriteAddress(viewModel: viewModel)
//        case .dismiss:
//            dismiss(animated: true)
//        }
//    }
//    
//    private func updateDataSource(section: [WriteDetailSection]) {
//        var snapshot = WriteDetailSanpshot()
//        
//        section.forEach {
//            snapshot.appendSections([$0])
//            snapshot.appendItems($0.items)
//        }
//        
//        dataSource.apply(snapshot, animatingDifferences: true)
//    }
//    
//    private func observeKeyboardEvent() {
//        NotificationCenter.default.addObserver(self, selector: #selector(onShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(onHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//    
//    private func presentCategorySelection(_ viewModel: CategorySelectionViewModel) {
//        let viewController = CategorySelectionViewController(viewModel: viewModel)
//        
//        presentPanModal(viewController)
//    }
//    
//    private func presentMapDetail(location: LocationResponse, storeName: String) {
//        let viewController = Environment.storeInterface.getMapDetailViewController(location: location, storeName: storeName)
//        present(viewController, animated: true)
//    }
//    
//    private func presentWriteAddress(viewModel: WriteAddressViewModel) {
//        let viewController = WriteAddressViewController(viewModel: viewModel)
//        viewController.modalPresentationStyle = .overCurrentContext
//        
//        present(viewController, animated: true)
//    }
//    
//    @objc func onShowKeyboard(notification: NSNotification) {
//        guard let userInfo = notification.userInfo,
//              let keyboardRect: CGRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
//        let keyboardHeight: CGFloat = keyboardRect.height
//        
//        writeDetailView.updateCollectionViewLayout(keyboardHeight: keyboardHeight)
//    }
//    
//    @objc func onHideKeyboard(notification: NSNotification) {
//        writeDetailView.updateCollectionViewLayout(keyboardHeight: 0)
//    }
//}
