import UIKit

import Common
import DesignSystem
import Log
import Model

struct MainTabBarItem: Equatable {
    static let iconSize: CGFloat = 24
    static let maxCount = 5

    enum Destination: Equatable {
        case native(TabBarTag)
        case web(URL)
        case deeplink(SDLink)
    }

    let id: String
    let destination: Destination
    let title: String
    let icon: UIImage?
    let iconUrl: String?
    let selectedTintColor: UIColor
    let clickLog: SDClickLog?

    var tag: TabBarTag? {
        guard case .native(let tag) = destination else { return nil }
        return tag
    }

    static let all: [MainTabBarItem] = [
        .fallback(tag: .home, title: Strings.TabBar.home, icon: DesignSystemAsset.Icons.homeSolid.image),
        .fallback(tag: .write, title: Strings.TabBar.write, icon: DesignSystemAsset.Icons.plus.image),
        .fallback(tag: .community, title: Strings.TabBar.community, icon: DesignSystemAsset.Icons.communitySolid.image),
        .fallback(tag: .my, title: Strings.TabBar.myPage, icon: DesignSystemAsset.Icons.mySolid.image)
    ]

    static func items(from response: BottomNavigationResponse?, webBaseURL: URL? = WebTabURL.baseURL) -> [MainTabBarItem] {
        guard let response else { return all }

        var usedTags = Set<TabBarTag>()
        var items: [MainTabBarItem] = []
        for tab in response.tabs {
            guard let item = MainTabBarItem(response: tab, webBaseURL: webBaseURL) else { continue }
            if let tag = item.tag {
                guard usedTags.insert(tag).inserted else { continue }
            }
            items.append(item)
        }

        let visibleItems = Array(items.prefix(maxCount))
        guard visibleItems.contains(where: { $0.tag == .home }) else { return all }
        return visibleItems
    }

    static func initialIndex(of items: [MainTabBarItem]) -> Int {
        switch items.first?.destination {
        case .native(.write), .deeplink, .none:
            return items.firstIndex { $0.tag == .home } ?? 0
        case .native, .web:
            return 0
        }
    }

    private static func fallback(tag: TabBarTag, title: String, icon: UIImage) -> MainTabBarItem {
        MainTabBarItem(
            id: tag.tabId,
            destination: .native(tag),
            title: title,
            icon: icon,
            iconUrl: nil,
            selectedTintColor: Colors.mainRed.color,
            clickLog: nil
        )
    }

    private init(
        id: String,
        destination: Destination,
        title: String,
        icon: UIImage?,
        iconUrl: String?,
        selectedTintColor: UIColor,
        clickLog: SDClickLog?
    ) {
        self.id = id
        self.destination = destination
        self.title = title
        self.icon = icon
        self.iconUrl = iconUrl
        self.selectedTintColor = selectedTintColor
        self.clickLog = clickLog
    }

    private init?(response: BottomNavigationItem, webBaseURL: URL?) {
        guard let destination = Self.destination(of: response, webBaseURL: webBaseURL) else { return nil }

        let fallbackIcon = Self.all.first { $0.tag == destination.tag }?.icon
        self.init(
            id: response.id,
            destination: destination,
            title: response.label,
            icon: fallbackIcon,
            iconUrl: response.icon.url,
            selectedTintColor: UIColor(hex: response.selectedTintColor) ?? Colors.mainRed.color,
            clickLog: response.clickLog
        )
    }
}

private extension MainTabBarItem {
    static func destination(of response: BottomNavigationItem, webBaseURL: URL?) -> Destination? {
        switch response.type {
        case .appDefined:
            return TabBarTag(tabId: response.id).map(Destination.native)
        case .dynamic:
            return dynamicDestination(link: response.link, webBaseURL: webBaseURL)
        case .unknown:
            return nil
        case .none:
            if let tag = TabBarTag(tabId: response.id) {
                return .native(tag)
            }
            guard response.link?.type == .web else { return nil }
            return dynamicDestination(link: response.link, webBaseURL: webBaseURL)
        }
    }

    static func dynamicDestination(link: SDLink?, webBaseURL: URL?) -> Destination? {
        guard let link else { return nil }

        switch link.type {
        case .web:
            return WebTabURL.resolve(link.link, baseURL: webBaseURL).map(Destination.web)
        case .appScheme:
            return link.link.isEmpty ? nil : .deeplink(link)
        case .store, .unknown:
            return nil
        }
    }
}

private extension MainTabBarItem.Destination {
    var tag: TabBarTag? {
        guard case .native(let tag) = self else { return nil }
        return tag
    }
}

enum WebTabURL {
    static var baseURL: URL? {
        #if DEBUG
        return URL(string: "https://echo.dev.threedollars.co.kr")
        #else
        return URL(string: "https://web.threedollars.co.kr")
        #endif
    }

    static func resolve(_ link: String, baseURL: URL?) -> URL? {
        let trimmed = link.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isNotEmpty else { return nil }

        if let url = URL(string: trimmed), url.scheme?.lowercased() == "https", url.host.isNotNil {
            return url
        }

        guard trimmed.hasPrefix("/"), let baseURL else { return nil }
        return URL(string: trimmed, relativeTo: baseURL)?.absoluteURL
    }
}

extension TabBarTag {
    init?(tabId: String) {
        switch tabId.lowercased() {
        case "home":
            self = .home
        case "store_create":
            self = .write
        case "community":
            self = .community
        case "my":
            self = .my
        default:
            return nil
        }
    }

    var tabId: String {
        switch self {
        case .home: return "home"
        case .write: return "store_create"
        case .community: return "community"
        case .my: return "my"
        }
    }

    var logObjectId: LogObjectId {
        switch self {
        case .home: return .home
        case .write: return .write
        case .community: return .community
        case .my: return .myPage
        }
    }
}
