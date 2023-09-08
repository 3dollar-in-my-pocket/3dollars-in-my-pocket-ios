import UIKit
import Combine

import DesignSystem

final class PollCategoryTabViewController: BaseViewController {

    private let navigationBar = CommunityNavigationBar(title: "맛대맛 투표")
    private let tabView = CommunityTabView(titles: ["실시간 참여순", "최신순"])
    private let pageContainerView = UIView()
    private let pageViewController = BasePageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    private lazy var pageContentViewControllers: [PollListViewController] = {
        return [
            PollListViewController(),
            PollListViewController()
        ]
    }()
    private let createPollButton = UIButton().then {
        $0.backgroundColor = Colors.mainRed.color
        $0.layer.cornerRadius = 22
        $0.clipsToBounds = true
        $0.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
        $0.titleLabel?.font = Fonts.Pretendard.semiBold.font(size: 14)
        $0.setTitle("투표 만들기 0/1회", for: .normal)
        $0.setTitleColor(Colors.systemWhite.color, for: .normal)
        $0.setImage(Icons.fireSolid.image
            .resizeImage(scaledTo: 20)
            .withTintColor(Colors.systemWhite.color), for: .normal)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 8, height: 8)
        $0.layer.shadowOpacity = 0.1
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func bindEvent() {
        super.bindEvent()

        tabView.didTap
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.changePage(to: index)
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
    }

    private func setupUI() {
        view.backgroundColor = Colors.gray0.color

        view.addSubViews([
            navigationBar,
            tabView,
            createPollButton
        ])

        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }

        tabView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        createPollButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 147, height: 44))
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
        }

        setupPageViewController()

        view.bringSubviewToFront(createPollButton)
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

        changePage(to: .zero)
    }

    private func changePage(to index: Int) {
        guard let viewController = pageContentViewControllers[safe: index] else { return }

        var direction: UIPageViewController.NavigationDirection = .forward
        let currentIndex = pageContentViewControllers.firstIndex(where: {
            $0 == pageViewController.viewControllers?.first
        })

        if let currentIndex, index < currentIndex {
            direction = .reverse
        }

        pageViewController.setViewControllers(
            [viewController],
            direction: direction,
            animated: true
        )
    }
}

// MARK: - UIPageViewControllerDataSource
extension PollCategoryTabViewController: UIPageViewControllerDataSource {
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
extension PollCategoryTabViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let changedViewController = pageViewController.viewControllers?.first as? PollListViewController,
              let changedIndex = pageContentViewControllers.firstIndex(of: changedViewController) else { return }

        tabView.updateSelect(changedIndex)
    }
}
