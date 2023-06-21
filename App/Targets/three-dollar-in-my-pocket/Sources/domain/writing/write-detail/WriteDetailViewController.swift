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
    }
    
    static func instance(location: Location, address: String) -> WriteDetailViewController {
        return WriteDetailViewController(location: location, address: address)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = writeDetailView
        coordinator = self
        observeKeyboardEvent()
        viewModel.input.viewDidLoad.send(())
    }
    
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
            
        case .presentCategorySelection(let selectedCategories):
            coordinator?.presentCategorySelection(selectedCategories: selectedCategories)
            
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
    
    private func observeKeyboardEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(onShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func onShowKeyboard(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardRect: CGRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight: CGFloat = keyboardRect.height
        
        writeDetailView.updateCollectionViewLayout(keyboardHeight: keyboardHeight)
    }
    
    @objc func onHideKeyboard(notification: NSNotification) {
        writeDetailView.updateCollectionViewLayout(keyboardHeight: 0)
    }
}

extension WriteDetailViewController: CategorySelectionDelegate {
    func onSelectCategories(categories: [PlatformStoreCategory]) {
        viewModel.input.addCategories.send(categories)
    }
}
