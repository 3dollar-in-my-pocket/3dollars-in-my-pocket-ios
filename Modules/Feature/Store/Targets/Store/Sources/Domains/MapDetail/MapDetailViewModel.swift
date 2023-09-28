import UIKit
import CoreLocation
import Combine

import Common
import Model
import DependencyInjection
import AppInterface

final class MapDetailViewModel: BaseViewModel {
    struct Input {
        let didTapNavigation = PassthroughSubject<Void, Never>()
        let didTapNavigationAction = PassthroughSubject<NavigationAppType, Never>()
    }
    
    struct Output {
        let storeLocation: CurrentValueSubject<CLLocation, Never>
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        let storeDetailData: StoreDetailData
    }
    
    struct Config {
        let storeDetailData: StoreDetailData
    }
    
    enum Route {
        case presentNavigationActionSheet
    }
    
    let input = Input()
    let output: Output
    private var state: State
    
    init(config: Config) {
        self.state = State(storeDetailData: config.storeDetailData)
        
        let location = CLLocation(
            latitude: config.storeDetailData.overview.location.latitude,
            longitude: config.storeDetailData.overview.location.longitude
        )
        self.output = Output(storeLocation: .init(location))
    }
    
    override func bind() {
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
        guard let appInfomation = DIContainer.shared.container.resolve(AppInfomation.self) else { return }
        let location = state.storeDetailData.overview.location
        let storeName = state.storeDetailData.overview.storeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
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
