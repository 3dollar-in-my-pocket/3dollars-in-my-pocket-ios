import UIKit
import Combine

import DependencyInjection
import CommunityInterface
import Model

public final class CommunityInterfaceImpl: CommunityInterface {
    public func getPollDetailViewController(pollId: String) -> UIViewController {
        let viewModel = PollDetailViewModel(pollId: pollId)
        return PollDetailViewController(viewModel)
    }
}

public extension CommunityInterfaceImpl {
    static func registerCommunityInterface() {
        DIContainer.shared.container.register(CommunityInterface.self) { _ in
            return CommunityInterfaceImpl()
        }
    }
}
