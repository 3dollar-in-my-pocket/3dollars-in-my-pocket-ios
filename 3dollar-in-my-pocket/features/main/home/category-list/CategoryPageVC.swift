import UIKit

protocol CategoryPageDelegate: class {
    func onScrollPage(index: Int)
}

class CategoryPageVC: UIPageViewController {
    weak var pageDelegate: CategoryPageDelegate?
    
    lazy var controllers = [CategoryChildVC.instance(category: .BUNGEOPPANG, latitude: self.latitude, longitude: self.longitude),
                       CategoryChildVC.instance(category: .TAKOYAKI, latitude: self.latitude, longitude: self.longitude),
                       CategoryChildVC.instance(category: .GYERANPPANG, latitude: self.latitude, longitude: self.longitude),
                       CategoryChildVC.instance(category: .HOTTEOK, latitude: self.latitude, longitude: self.longitude)]
    
    var category: StoreCategory!
    var latitude: Double!
    var longitude: Double!
    
    static func instance(category: StoreCategory, latitude: Double, longitude: Double) -> CategoryPageVC {
        return CategoryPageVC.init(transitionStyle: .scroll, navigationOrientation: .horizontal).then {
            $0.category = category
            $0.latitude = latitude
            $0.longitude = longitude
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        setViewControllers([controllers[StoreCategory.categoryToIndex(category)]], direction: .forward, animated: true, completion: nil)
    }
    
    func tapCategory(index: Int) {
        if let firstVC = viewControllers?.first as? CategoryChildVC,
            let currentIndex = self.controllers.firstIndex(of: firstVC) {
            if currentIndex < index {
                setViewControllers([controllers[index]], direction: .forward, animated: true, completion: nil)
            } else {
                setViewControllers([controllers[index]], direction: .reverse, animated: true, completion: nil)
            }
        }
    }
}

extension CategoryPageVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = controllers.firstIndex(of: viewController as! CategoryChildVC) else {
            return nil
        }
        let previousIndex = index - 1
        guard previousIndex >= 0 else {
            return controllers.last
        }
        guard controllers.count > previousIndex else {
            return nil
        }
        return controllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = controllers.firstIndex(of: viewController as! CategoryChildVC) else {
            return nil
        }
        let nextIndex = index + 1
        guard nextIndex < controllers.count else {
            return controllers.first
        }
        guard controllers.count > nextIndex else {
            return nil
        }
        return controllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
            let firstVC = pageViewController.viewControllers?.first as? CategoryChildVC,
            let currentIndex = self.controllers.firstIndex(of: firstVC) {
            self.pageDelegate?.onScrollPage(index: currentIndex)
        }
    }
}
