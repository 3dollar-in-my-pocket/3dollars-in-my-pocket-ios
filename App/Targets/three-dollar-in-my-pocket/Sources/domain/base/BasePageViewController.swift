import UIKit
import Combine

class BasePageViewController: UIPageViewController, UIScrollViewDelegate {

    let transitionInProgress = CurrentValueSubject<Bool, Never>(false)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        delegate = self
    }

    override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
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

extension BasePageViewController {
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
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        transitionInProgress.send(true)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        transitionInProgress.send(false)
    }
}
