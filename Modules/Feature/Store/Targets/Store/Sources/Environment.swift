import DesignSystem
import AppInterface
import DependencyInjection
import WriteInterface

typealias Fonts = DesignSystemFontFamily.Pretendard
typealias Colors = DesignSystemAsset.Colors
typealias Icons = DesignSystemAsset.Icons
typealias Assets = StoreAsset
typealias Strings = StoreStrings

final class Environment {
    static var appModuleInterface: AppModuleInterface {
        guard let appModuleInterface = DIContainer.shared.container.resolve(AppModuleInterface.self) else {
            fatalError("AppModuleInterface가 정의되지 않았습니다.")
        }
        
        return appModuleInterface
    }
    
    static var writeInterface: WriteInterface {
        guard let writeInterface = DIContainer.shared.container.resolve(WriteInterface.self) else {
            fatalError("WriteInterface가 정의되지 않았습니다.")
        }
        
        return writeInterface
    }
}
