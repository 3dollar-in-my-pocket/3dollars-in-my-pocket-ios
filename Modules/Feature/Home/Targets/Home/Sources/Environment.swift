import DesignSystem
import Resource
import AppInterface
import MembershipInterface
import StoreInterface
import DependencyInjection

typealias Fonts = DesignSystemFontFamily.Pretendard
typealias Colors = DesignSystemAsset.Colors
typealias Icons = DesignSystemAsset.Icons
typealias Assets = HomeAsset
typealias Strings = HomeStrings


final class Environment {
    static var appModuleInterface: AppModuleInterface {
        guard let appModuleInterface = DIContainer.shared.container.resolve(AppModuleInterface.self) else {
            fatalError("AppModuleInterface가 정의되지 않았습니다.")
        }
        
        return appModuleInterface
    }
    
    static var membershipInterface: MembershipInterface {
        guard let membershipInterface = DIContainer.shared.container.resolve(MembershipInterface.self) else {
            fatalError("MembershipInterface가 정의되지 않았습니다.")
        }
        
        return membershipInterface
    }
    
    static var storeInterface: StoreInterface {
        guard let storeInterface = DIContainer.shared.container.resolve(StoreInterface.self) else {
            fatalError("StoreInterface가 정의되지 않았습니다.")
        }
        
        return storeInterface
    }
}
