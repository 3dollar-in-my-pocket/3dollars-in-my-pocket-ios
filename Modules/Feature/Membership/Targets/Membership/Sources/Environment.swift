import DesignSystem
import DependencyInjection
import AppInterface
import MyPageInterface

typealias Fonts = DesignSystemFontFamily.Pretendard
typealias Colors = DesignSystemAsset.Colors
typealias Icons = DesignSystemAsset.Icons
typealias Assets = MembershipAsset
typealias Strings = MembershipStrings

final class Environment {
    static var appModuleInterface: AppModuleInterface {
        guard let appModuleInterface = DIContainer.shared.container.resolve(AppModuleInterface.self) else {
            fatalError("AppModuleInterface가 정의되지 않았습니다.")
        }
        
        return appModuleInterface
    }
    
    static var myPageInterface: MyPageInterface {
        guard let myPageInterface = DIContainer.shared.container.resolve(MyPageInterface.self) else {
            fatalError("MyPageInterface가 정의되지 않았습니다.")
        }
        
        return myPageInterface
    }
}
