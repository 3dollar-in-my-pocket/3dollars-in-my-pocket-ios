import UIKit

public protocol CommunityInterface {
    func getPollDetailViewController(pollId: String) -> UIViewController
}
