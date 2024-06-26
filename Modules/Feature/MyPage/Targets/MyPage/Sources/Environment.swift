import DesignSystem
import DependencyInjection
import MyPageInterface
import AppInterface
import StoreInterface
import CommunityInterface
import MembershipInterface

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
    
    static var communityInterface: CommunityInterface {
        guard let communityInterface = DIContainer.shared.container.resolve(CommunityInterface.self) else {
            fatalError("CommunityInterface가 정의되지 않았습니다.")
        }
        
        return communityInterface
    }
    
    static var membershipInterface: MembershipInterface {
        guard let membershipInterface = DIContainer.shared.container.resolve(MembershipInterface.self) else {
            fatalError("MembershipInterface가 정의되지 않았습니다.")
        }
        
        return membershipInterface
    }
}
