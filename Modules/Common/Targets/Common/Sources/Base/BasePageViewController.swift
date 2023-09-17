import UIKit
import Combine

public class BasePageViewController: UIPageViewController, UIScrollViewDelegate {

    public let transitionInProgress = CurrentValueSubject<Bool, Never>(false)

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    public func setupUI() {
        delegate = self
    }

    public override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard !transitionInProgress.value else { return }

        transitionInProgress.send(true)

        super.setViewControllers(
            viewControllers,
            direction: direction,
            animated: animated,
            completion: { [weak self] result in
                completion?(result)
                self?.transitionInProgress.send(false)
            }
        )
    }
}

public extension BasePageViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        transitionInProgress.send(false)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            transitionInProgress.send(false)
        }
    }
}

extension BasePageViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        transitionInProgress.send(true)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        transitionInProgress.send(false)
    }
}
