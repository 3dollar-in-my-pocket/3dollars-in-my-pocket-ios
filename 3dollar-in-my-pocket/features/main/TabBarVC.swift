import UIKit

class TabBarVC: UITabBarController {
  
  static func instance() -> TabBarVC {
    return TabBarVC(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupTabBarController()
    self.delegate = self
  }
  
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    self.tabBar.barTintColor = item.tag == TabBarTag.my.rawValue ? UIColor(r: 46, g: 46, b: 46) : .white
    
    if item.tag == TabBarTag.my.rawValue {
      self.tabBar.barTintColor = UIColor(r: 46, g: 46, b: 46)
    } else {
      self.tabBar.barTintColor = .white
    }
  }
  
  private func setupTabBarController() {
    self.setViewControllers([
      HomeVC.instance(),
      CategoryListVC.instance(category: .BUNGEOPPANG),
      WriteAddressVC.instance(delegate: self),
      MyPageVC.instance(),
    ], animated: true)
    self.tabBar.tintColor = UIColor(r: 255, g: 92, b: 67)
    self.tabBar.layer.borderWidth = 0
    self.tabBar.layer.borderColor = UIColor.clear.cgColor
    self.tabBar.clipsToBounds = true
    self.tabBar.barTintColor = .white
  }
}

extension TabBarVC: WriteAddressDelegate {
  func onWriteSuccess(storeId: Int) {
    
  }
}

extension TabBarVC: UITabBarControllerDelegate {
  
  func tabBarController(
    _ tabBarController: UITabBarController,
    shouldSelect viewController: UIViewController
  ) -> Bool {
    if let navigationVC = viewController as? UINavigationController {
      if navigationVC.topViewController is WriteAddressVC {
        let writeVC = WriteAddressVC.instance(delegate: self)
        
        self.present(writeVC, animated: true, completion: nil)
        return false
      }
    }
    return true
  }
}
