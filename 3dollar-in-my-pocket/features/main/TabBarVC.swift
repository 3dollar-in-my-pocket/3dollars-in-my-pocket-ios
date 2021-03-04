import UIKit

class TabBarVC: UITabBarController {
  
  private let loadingView = LoadingView()
  private lazy var dimView = UIView(frame: self.view.frame).then {
    $0.backgroundColor = .clear
  }
  
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
  
  func showLoading(isShow: Bool) {
    if isShow {
      self.view.addSubview(loadingView)
      self.loadingView.snp.makeConstraints { (make) in
        make.edges.equalTo(0)
      }
      self.view.isUserInteractionEnabled = false
      self.loadingView.startLoading()
    } else {
      self.loadingView.stopLoading()
      self.view.isUserInteractionEnabled = true
      self.loadingView.removeFromSuperview()
    }
  }
  
  func showDim(isShow: Bool) {
    if isShow {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.view.addSubview(self.dimView)
        UIView.animate(withDuration: 0.3) {
          self.dimView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a:0.5)
        }
      }
    } else {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        UIView.animate(withDuration: 0.3, animations: {
          self.dimView.backgroundColor = .clear
        }) { (_) in
          self.dimView.removeFromSuperview()
        }
      }
    }
  }
  
  private func setupTabBarController() {
    self.setViewControllers([
      HomeVC.instance(),
      CategoryVC.instance(),
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
    self.selectedIndex = 0
    if let navigationVC = self.viewControllers?[0] as? UINavigationController,
       let homeVC = navigationVC.topViewController as? HomeVC {
      homeVC.goToDetail(storeId: storeId)
    }
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
