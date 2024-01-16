import DesignSystem
import DependencyInjection
import MyPageInterface
import AppInterface
import StoreInterface

typealias Fonts = DesignSystemFontFamily.Pretendard
typealias Colors = DesignSystemAsset.Colors
typealias Icons = DesignSystemAsset.Icons


final class Environment {
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
