import UIKit

final class PolicyView: BaseView {
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 30
        $0.backgroundColor = R.color.gray70()
    }
}
