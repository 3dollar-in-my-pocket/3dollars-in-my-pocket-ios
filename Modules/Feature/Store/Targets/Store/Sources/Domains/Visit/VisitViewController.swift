import UIKit
import CoreLocation

import Common
import Model
import DesignSystem
import Log

import CombineCocoa

final class VisitViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    private let visitView = VisitView()
    private let viewModel: VisitViewModel
    
    init(viewModel: VisitViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = visitView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.input.viewWillAppear.send(())
    }
    
    private func bind() {
        visitView.closeButton.tapPublisher
            .main
            .withUnretained(self)
            .sink { (owner: VisitViewController, _) in
                owner.dismiss(animated: true, completion: nil)
            }
            .store(in: &cancellables)
        
        // Input
        visitView.currentLocationButton.tapPublisher
            .mapVoid
            .subscribe(viewModel.input.didTapCurrentLocation)
            .store(in: &cancellables)
        
        visitView.existedButton.tapPublisher
            .map { _ in VisitType.exists }
            .subscribe(viewModel.input.didTapVisit)
            .store(in: &cancellables)
        
        visitView.notExistedButton.tapPublisher
            .map { _ in VisitType.notExists }
            .subscribe(viewModel.input.didTapVisit)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.store
            .main
            .withUnretained(self)
            .sink { (owner: VisitViewController, store: VisitableStore) in
                owner.visitView.bind(store: store)
            }
            .store(in: &cancellables)
        
        viewModel.output.distance
            .main
            .withUnretained(self)
            .sink { (owner: VisitViewController, distance: Int) in
                owner.visitView.bindDistance(distance: distance)
            }
            .store(in: &cancellables)
        
        viewModel.output.canVisit
            .main
            .withUnretained(self)
            .sink { (owner: VisitViewController, canVisit: Bool) in
                owner.visitView.bindVisitable(canVisit: canVisit)
            }
            .store(in: &cancellables)
        
        viewModel.output.moveCamera
            .main
            .withUnretained(self)
            .sink { (owner: VisitViewController, location: CLLocation) in
                owner.visitView.moveCamera(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { (message: String) in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: VisitViewController, route: VisitViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
}

// MARK: Route
extension VisitViewController {
    private func handleRoute(_ route: VisitViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true, completion: nil)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}
