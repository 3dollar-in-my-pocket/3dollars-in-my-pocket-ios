import AppInterface
import DependencyInjection

final class Environment {
    static var appModuleInterface: AppModuleInterface {
        guard let appModuleInterface = DIContainer.shared.resolver.resolve(AppModuleInterface.self) else {
            fatalError("AppModuleInterface이 정의되지 않았습니다.")
        }
        
        return appModuleInterface
    }
}
