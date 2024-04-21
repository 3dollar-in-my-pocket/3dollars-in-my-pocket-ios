import UIKit
import Combine

import DesignSystem
import Common
import Log
import Model

final class ReviewTabViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }

    private lazy var navigationBar = MyPageNavigationBar(title: "내가 쓴 리뷰")
    private let tabView = MyPageTabView(titles: ReviewTab.list.map { $0.title }).then {
        $0.isUserInteractionEnabled = false
    }
    private let lineView: UIView = UIView().then {
        $0.backgroundColor = Colors.gray90.color
    }
    private let pageContainerView = UIView()
    private let pageViewController = BasePageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    private var pageContentViewControllers: [UIViewController] = []

    private let viewModel: ReviewTabViewModel

    init(viewModel: ReviewTabViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        viewModel.input.firstLoad.send()
    }

    private func setupUI() {
        view.backgroundColor = Colors.gray100.color

        view.addSubViews([
            navigationBar,
            lineView,
            tabView,
        ])

        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }

        tabView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        lineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabView)
            $0.height.equalTo(1)
        }
        
        setupPageViewController()
    }

    private func setupPageViewController() {
        addChild(pageViewController)
        pageContainerView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
        pageViewController.dataSource = self
        pageViewController.delegate = self

        view.addSubview(pageContainerView)
        pageContainerView.snp.makeConstraints {
            $0.top.equalTo(tabView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        pageContentViewControllers = ReviewTab.list.map {
            switch $0 {
            case .store:
                return StoreReviewListViewController()
            case .bossStore:
                return BossStoreReviewListViewController()
            }
        }
        changePage(to: .zero, animated: false)
        tabView.isUserInteractionEnabled = true
    }
    
    private func changePage(to index: Int, animated: Bool) {
        guard let viewController = pageContentViewControllers[safe: index] else { return }
        
        var direction: UIPageViewController.NavigationDirection = .forward
        let currentIndex = pageContentViewControllers.firstIndex(where: {
            $0 == pageViewController.viewControllers?.first
        }) ?? 0

        if index < currentIndex {
            direction = .reverse
        }

        pageViewController.setViewControllers(
            [viewController],
            direction: direction,
            animated: animated)
    }

    override func bindEvent() {
        super.bindEvent()

        pageViewController.transitionInProgress
            .main
            .removeDuplicates()
            .withUnretained(self)
            .sink { owner, transitionInProgress in
                owner.tabView.isUserInteractionEnabled = !transitionInProgress
            }
            .store(in: &cancellables)
        
        tabView.didTap
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.changePage(to: index, animated: true)
            }
            .store(in: &cancellables)

        navigationBar.backButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)

        // Output
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .none: break
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: ReviewTabViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.changeTab
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.tabView.updateSelect(index)
                owner.changePage(to: index, animated: false)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UIPageViewControllerDataSource
extension ReviewTabViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pageContentViewControllers.firstIndex(where: { $0 == viewController }) else { return nil }

        return pageContentViewControllers[safe: index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pageContentViewControllers.firstIndex(where: { $0 == viewController }) else { return nil }

        return pageContentViewControllers[safe: index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension ReviewTabViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let changedViewController = pageViewController.viewControllers?.first as? UIViewController,
              let changedIndex = pageContentViewControllers.firstIndex(of: changedViewController) else { return }

        tabView.updateSelect(changedIndex)
    }
}
