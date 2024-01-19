import DesignSystem
import DependencyInjection
import MyPageInterface
import AppInterface
import StoreInterface

typealias Fonts = DesignSystemFontFamily.Pretendard
typealias Colors = DesignSystemAsset.Colors
typealias Icons = DesignSystemAsset.Icons

typealias Images = MyPageAsset
typealias Strings = MyPageStrings

final class Environment {
    static var appModuleInterface: AppModuleInterface {
        guard let appModuleInterface = DIContainer.shared.container.resolve(AppModuleInterface.self) else {
            fatalError("AppModuleInterface가 정의되지 않았습니다.")
        }
        
        return appModuleInterface
    }
    
    static var storeInterface: StoreInterface {
        guard let storeInterface = DIContainer.shared.container.resolve(StoreInterface.self) else {
            fatalError("StoreInterface가 정의되지 않았습니다.")
        }
        
        return storeInterface
    }
    
    static var myPageInterface: MyPageInterface {
        guard let myPageInterface = DIContainer.shared.container.resolve(MyPageInterface.self) else {
            fatalError("MyPageInterface가 정의되지 않았습니다.")
        }
        
        return myPageInterface
    }
}
