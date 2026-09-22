import UIKit

import DesignSystem
import Log
import Model

struct MainTabBarItem {
    static let iconSize: CGFloat = 24

    let tag: TabBarTag
    let title: String
    let icon: UIImage

    static let all: [MainTabBarItem] = [
        MainTabBarItem(tag: .home, title: Strings.TabBar.home, icon: DesignSystemAsset.Icons.homeSolid.image),
        MainTabBarItem(tag: .write, title: Strings.TabBar.write, icon: DesignSystemAsset.Icons.plus.image),
        MainTabBarItem(tag: .community, title: Strings.TabBar.community, icon: DesignSystemAsset.Icons.communitySolid.image),
        MainTabBarItem(tag: .my, title: Strings.TabBar.myPage, icon: DesignSystemAsset.Icons.mySolid.image)
    ]
}

extension TabBarTag {
    var logObjectId: LogObjectId {
        switch self {
        case .home: return .home
        case .write: return .write
        case .community: return .community
        case .my: return .myPage
        }
    }
}
