import DependencyInjection
import StoreInterface

final class Environment {
    static var storeInterface: StoreInterface {
        guard let storeInterface = DIContainer.shared.container.resolve(StoreInterface.self) else {
            fatalError("AppModuleInterface가 정의되지 않았습니다.")
        }
        
        return storeInterface
    }
}
