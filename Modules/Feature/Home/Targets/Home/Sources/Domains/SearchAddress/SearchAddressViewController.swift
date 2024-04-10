import UIKit
import CoreLocation

import Common
import Model
import Log

final class SearchAddressViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let searchAddressView = SearchAddressView()
    private let viewModel: SearchAddressViewModel
    private lazy var datasource = SearchAddressDatasource(collectionView: searchAddressView.addressCollectionView, viewModel: viewModel)
    
    init(viewModel: SearchAddressViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = searchAddressView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = searchAddressView
        searchAddressView.addressCollectionView.dataSource = datasource
        viewModel.input.firstLoad.send()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchAddressView.showKeyboard()
    }
    
    override func bindViewModelInput() {
        searchAddressView.addressField.textPublisher
            .subscribe(viewModel.input.inputKeyword)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.sections
            .main
            .withUnretained(self)
            .sink { (owner: SearchAddressViewController, sections: [SearchAddressSection]) in
                owner.datasource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.isHiddenClear
            .main
            .assign(to: \.isHidden, on: searchAddressView.clearButton)
            .store(in: &cancellables)
        
        viewModel.output.hideKeyboard
            .main
            .withUnretained(self)
            .sink { (owner: SearchAddressViewController, _) in
                owner.searchAddressView.hideKeyboard()
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: SearchAddressViewController, route: SearchAddressViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: SearchAddressViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
    
    override func bindEvent() {
        searchAddressView.closeButton.controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink(receiveValue: { (owner: SearchAddressViewController, _) in
                owner.dismiss(animated: true)
            })
            .store(in: &cancellables)
        
        searchAddressView.clearButton.controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink(receiveValue: { (owner: SearchAddressViewController, _) in
                owner.searchAddressView.clearButton.isHidden = true
                owner.searchAddressView.addressField.text = nil
                owner.viewModel.input.didTapClearButton.send()
            })
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: SearchAddressViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true)
        }
    }
}
