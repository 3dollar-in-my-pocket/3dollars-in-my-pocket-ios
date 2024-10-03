import UIKit
import CoreLocation
import Combine

import Common
import Model
import DependencyInjection
import AppInterface

public final class MapDetailViewModel: BaseViewModel {
    struct Input {
        let didTapNavigation = PassthroughSubject<Void, Never>()
        let didTapNavigationAction = PassthroughSubject<NavigationAppType, Never>()
    }
    
    struct Output {
        let storeLocation: CurrentValueSubject<CLLocation, Never>
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        let location: LocationResponse
        let storeName: String
    }
    
    public struct Config {
        let location: LocationResponse
        let storeName: String
    }
    
    enum Route {
        case presentNavigationActionSheet
    }
    
    let input = Input()
    let output: Output
    private var state: State
    
    public init(config: Config) {
        self.state = State(location: config.location, storeName: config.storeName)
        
        let location = CLLocation(
            latitude: config.location.latitude,
            longitude: config.location.longitude
        )
        self.output = Output(storeLocation: .init(location))
    }
    
    public override func bind() {
        input.didTapNavigation
            .map { Route.presentNavigationActionSheet }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.didTapNavigationAction
            .withUnretained(self)
            .sink { (owner: MapDetailViewModel, type: NavigationAppType) in
                owner.goToNavigationApplication(type: type)
            }
            .store(in: &cancellables)
    }
    
    private func goToNavigationApplication(type: NavigationAppType) {
        guard let appInfomation = DIContainer.shared.container.resolve(AppInformation.self) else { return }
        let location = state.location
        let storeName = state.storeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlScheme: String
        switch type {
        case .kakao:
            urlScheme = "kakaomap://look?p=\(location.latitude),\(location.longitude)"
            
        case .naver:
            urlScheme = "nmap://place?lat=\(location.latitude)&lng=\(location.longitude)&name=\(storeName)&zoom=20&appname=\(appInfomation.bundleId)"
        }
        
        guard let url = URL(string: urlScheme) else { return }
        UIApplication.shared.open(url)
    }
}
