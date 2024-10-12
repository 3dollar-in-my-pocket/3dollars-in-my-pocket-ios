import DesignSystem
import StoreInterface
import CommunityInterface
import MyPageInterface
import DependencyInjection
import MembershipInterface

typealias Fonts = DesignSystemFontFamily.Pretendard
typealias Colors = DesignSystemAsset.Colors
typealias Strings = ThreeDollarInMyPocketStrings
typealias Assets = ThreeDollarInMyPocketAsset
typealias Icons = DesignSystemAsset.Icons


final class Environment {
    static var storeInterface : StoreInterface {
        guard let storeInterface = DIContainer.shared.container.resolve(StoreInterface.self) else {
            fatalError("StoreInterface가 정의되지 않았습니다.")
        }
        
        return storeInterface
    }

    static var communityInterface: CommunityInterface {
        guard let communityInterface = DIContainer.shared.container.resolve(CommunityInterface.self) else {
            fatalError("StoreInterface가 정의되지 않았습니다.")
        }

        return communityInterface
    }
    
    static var myPageInterface: MyPageInterface {
        guard let myPageInterface = DIContainer.shared.container.resolve(MyPageInterface.self) else {
            fatalError("MyPageInterface가 정의되지 않았습니다.")
        }
        
        return myPageInterface
    }
    
    static var membershipInterface: MembershipInterface {
        guard let membershipInterface = DIContainer.shared.container.resolve(MembershipInterface.self) else {
            fatalError("MembershipInterface가 정의되지 않았습니다.")
        }
        
        return membershipInterface
    }
}
