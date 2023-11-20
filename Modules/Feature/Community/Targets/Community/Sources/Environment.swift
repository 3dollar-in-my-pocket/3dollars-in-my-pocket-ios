import DesignSystem
import DependencyInjection
import StoreInterface

typealias Fonts = DesignSystemFontFamily.Pretendard
typealias Colors = DesignSystemAsset.Colors
typealias Icons = DesignSystemAsset.Icons
//typealias Assets = StoreAsset
//typealias Strings = StoreStrings



final class Environment {
    static var storeInterface: StoreInterface {
        guard let storeInterface = DIContainer.shared.container.resolve(StoreInterface.self) else {
            fatalError("StoreInterface가 정의되지 않았습니다.")
        }
        
        return storeInterface
    }
}
