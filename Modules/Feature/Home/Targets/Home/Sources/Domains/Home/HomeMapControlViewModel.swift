import Foundation
import Combine
import CoreLocation

import Common
import Model
import Log

enum HomeMapControlButton: Equatable {
    case serverDriven(SDButton)
    case fallbackCurrentLocation
}

extension HomeMapControlViewModel {
    enum Constant {
        static let zoomLevelParamKey = "MAP_ZOOM_LEVEL"
    }

    struct Input {
        /// 필터 화면 응답의 `HOME_MAP_CONTROL` 섹션. nil 이면(섹션 없음·응답 실패) 현재 위치 버튼만 폴백으로 둔다.
        let setSection = PassthroughSubject<HomeMapControlSection?, Never>()
        let didTapControl = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let buttons = CurrentValueSubject<[HomeMapControlButton], Never>([.fallbackCurrentLocation])
        let moveToCurrentLocation = PassthroughSubject<(location: CLLocation, zoomLevel: Double?), Never>()
        /// 주변 가게 조회 dynamicParams 에 합성할 필터 값 (`focusFavoriteStores` 등).
        let filterParams = CurrentValueSubject<[String: String], Never>([:])
        let didChangeFilter = PassthroughSubject<Void, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    enum Route {
        case presentSigninDialog
        case showErrorAlert(Error)
    }

    struct State {
        var renderedControls: [(control: (any HomeMapControl)?, button: HomeMapControlButton)] = []
        var controls: [any HomeMapControl] = []
        var filterValues: [String: Bool] = [:]
        var isMovingToCurrentLocation = false
    }

    struct Dependency {
        let locationManager: LocationManagerProtocol
        let preference: Preference
        let logManager: LogManagerProtocol

        init(
            locationManager: LocationManagerProtocol = LocationManager.shared,
            preference: Preference = .shared,
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.locationManager = locationManager
            self.preference = preference
            self.logManager = logManager
        }
    }
}

final class HomeMapControlViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency

    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency

        super.init()
    }

    override func bind() {
        input.setSection
            .withUnretained(self)
            .sink { (owner: HomeMapControlViewModel, section: HomeMapControlSection?) in
                owner.applySection(section)
            }
            .store(in: &cancellables)

        input.didTapControl
            .withUnretained(self)
            .sink { (owner: HomeMapControlViewModel, index: Int) in
                owner.handleTap(at: index)
            }
            .store(in: &cancellables)
    }

    private func applySection(_ section: HomeMapControlSection?) {
        state.controls = section?.controls ?? []
        state.filterValues = [:]
        emitButtons()
        emitFilterParams()
    }

    private func emitButtons() {
        var rendered: [(control: (any HomeMapControl)?, button: HomeMapControlButton)] = []
        for control in state.controls {
            switch control {
            case let action as HomeMapActionControl:
                rendered.append((action, .serverDriven(action.button)))
            case let filter as HomeMapStoreFilterControl:
                guard let option = displayedOption(for: filter) else { continue }
                rendered.append((filter, .serverDriven(option.button)))
            default:
                continue
            }
        }
        if rendered.isEmpty {
            rendered = [(nil, .fallbackCurrentLocation)]
        }
        state.renderedControls = rendered
        output.buttons.send(rendered.map(\.button))
    }

    private func emitFilterParams() {
        var params: [String: String] = [:]
        for case let filter as HomeMapStoreFilterControl in state.controls {
            params[filter.paramKey] = String(currentValue(for: filter))
        }
        output.filterParams.send(params)
    }

    private func currentValue(for filter: HomeMapStoreFilterControl) -> Bool {
        state.filterValues[filter.paramKey] ?? false
    }

    /// 서버는 `paramValue` 를 "탭하면 적용될 값"으로 내려준다 (꺼짐 상태 → 빈 북마크 옵션의 paramValue 가 true).
    /// 그래서 현재 값과 다른 옵션이 지금 보여줄 버튼이다.
    private func displayedOption(for filter: HomeMapStoreFilterControl) -> HomeMapStoreFilterOption? {
        let current = currentValue(for: filter)
        return filter.options.first { $0.paramValue != current } ?? filter.options.first
    }

    private func handleTap(at index: Int) {
        guard let entry = state.renderedControls[safe: index] else { return }

        switch entry.button {
        case .fallbackCurrentLocation:
            sendFallbackCurrentLocationLog()
            moveToCurrentLocation(zoomLevel: nil)
        case .serverDriven(let button):
            sendClickLog(button.clickLog)
            if let action = entry.control as? HomeMapActionControl {
                handle(action)
            } else if let filter = entry.control as? HomeMapStoreFilterControl {
                toggle(filter)
            }
        }
    }

    private func handle(_ action: HomeMapActionControl) {
        guard let customAction = action.button.customAction else { return }

        switch customAction.actionType {
        case .homeMapControlMoveToCurrentLocation:
            let zoomLevel = customAction.extraParams[Constant.zoomLevelParamKey]?.doubleValue
            moveToCurrentLocation(zoomLevel: zoomLevel)
        default:
            break
        }
    }

    private func toggle(_ filter: HomeMapStoreFilterControl) {
        guard dependency.preference.isAnonymousUser.isNot else {
            output.route.send(.presentSigninDialog)
            return
        }
        guard let option = displayedOption(for: filter) else { return }

        state.filterValues[filter.paramKey] = option.paramValue
        emitButtons()
        emitFilterParams()
        output.didChangeFilter.send(())
    }

    private func moveToCurrentLocation(zoomLevel: Double?) {
        guard state.isMovingToCurrentLocation.isNot else { return }
        state.isMovingToCurrentLocation = true

        Task { @MainActor [weak self] in
            guard let self else { return }
            defer { state.isMovingToCurrentLocation = false }
            do {
                let location = try await dependency.locationManager.getCurrentLocation()
                dependency.preference.userCurrentLocation = location
                output.moveToCurrentLocation.send((location, zoomLevel))
            } catch {
                output.route.send(.showErrorAlert(error))
            }
        }
        .store(in: taskBag)
    }

    private func sendClickLog(_ clickLog: SDClickLog?) {
        guard let clickLog else { return }
        dependency.logManager.sendEvent(event: ClickEvent(clickLog: clickLog))
    }

    private func sendFallbackCurrentLocationLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: .home,
            objectType: .button,
            objectId: .currentLocation
        ))
    }
}
