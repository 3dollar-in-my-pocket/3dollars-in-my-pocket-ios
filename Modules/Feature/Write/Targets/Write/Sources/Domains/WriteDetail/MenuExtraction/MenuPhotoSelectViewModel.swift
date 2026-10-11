import Combine

import Common
import Log

extension MenuPhotoSelectViewModel {
    struct Input {
        let didTapAlbum = PassthroughSubject<Void, Never>()
        let didTapCamera = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let screenName: ScreenName = .writeDetailMenuPhotoPopup
        let route = PassthroughSubject<Route, Never>()
    }

    enum Route {
        case album
        case camera
    }

    struct Dependency {
        let logManager: LogManagerProtocol

        init(logManager: LogManagerProtocol = LogManager.shared) {
            self.logManager = logManager
        }
    }
}

final class MenuPhotoSelectViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let dependency: Dependency

    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()
    }

    override func bind() {
        input.didTapAlbum
            .sink { [weak self] in
                self?.sendClickLog(objectId: .selectPhoto)
                self?.output.route.send(.album)
            }
            .store(in: &cancellables)

        input.didTapCamera
            .sink { [weak self] in
                self?.sendClickLog(objectId: .takePhoto)
                self?.output.route.send(.camera)
            }
            .store(in: &cancellables)
    }

    private func sendClickLog(objectId: LogObjectId) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: objectId
        ))
    }
}
