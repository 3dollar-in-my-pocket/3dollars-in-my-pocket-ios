import UIKit

public protocol MyPageInterface {
    func getMyPageViewController() -> UIViewController
    func getMyMedalViewController() -> UIViewController
    func getBookmarkViewerViewController(folderId: String) -> UIViewController
}
