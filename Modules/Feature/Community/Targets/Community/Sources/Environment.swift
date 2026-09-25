import DesignSystem
import DependencyInjection
import StoreInterface
import AppInterface
import FeedInterface

typealias Fonts = DesignSystemFontFamily.Pretendard
typealias Colors = DesignSystemAsset.Colors
typealias Icons = DesignSystemAsset.Icons
typealias Assets = CommunityAsset
typealias Strings = CommunityStrings


final class Environment {
    static var storeInterface: StoreInterface {
        guard let storeInterface = DIContainer.shared.resolver.resolve(StoreInterface.self) else {
            fatalError("StoreInterface가 정의되지 않았습니다.")
        }
        
        return storeInterface
    }
    
    static var appModuleInterface: AppModuleInterface {
        guard let appModuleInterface = DIContainer.shared.resolver.resolve(AppModuleInterface.self) else {
            fatalError("AppModuleInterface가 정의되지 않았습니다.")
        }
        
        return appModuleInterface
    }

    static var feedInterface: FeedInterface {
        guard let feedInterface = DIContainer.shared.resolver.resolve(FeedInterface.self) else {
            fatalError("FeedInterface가 정의되지 않았습니다.")
        }

        return feedInterface
    }
}
