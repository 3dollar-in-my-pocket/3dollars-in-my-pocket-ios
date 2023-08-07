import UIKit

import Common

final class HomeListViewController: BaseViewController {
    private let homeListView = HomeListView()
    
    static func instance() -> UINavigationController {
        let viewController = HomeListViewController()
        
        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.interactivePopGestureRecognizer?.delegate = nil
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = homeListView
    }
}
