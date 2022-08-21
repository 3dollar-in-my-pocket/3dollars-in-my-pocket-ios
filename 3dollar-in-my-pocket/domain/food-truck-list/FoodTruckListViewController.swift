import UIKit

import Base
import RxSwift
import RxDataSources
import ReactorKit
import NMapsMap

final class FoodTruckListViewController: BaseViewController {
    
    static func instance() -> UINavigationController {
        let viewController = FoodTruckListViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(named: "ic_food_truck"),
                tag: TabBarTag.foodTruck.rawValue
            )
        }
        
        return UINavigationController(rootViewController: viewController).then {
            $0.setNavigationBarHidden(true, animated: false)
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}
