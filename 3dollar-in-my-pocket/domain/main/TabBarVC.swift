import UIKit
import RxSwift

class TabBarVC: UITabBarController {
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let disposeBag = DisposeBag()
    private let loadingView = LoadingView()
    private lazy var dimView = UIView(frame: self.view.frame).then {
        $0.backgroundColor = .clear
    }
    
    
    deinit {
        self.removeKakaoLinkObserver()
    }
    
    static func instance() -> TabBarVC {
        return TabBarVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkIfBannerExisted()
        self.setupTabBarController()
        self.addKakaoLinkObserver()
        self.processKakaoLinkIfExisted()
        self.feedbackGenerator.prepare()
        self.delegate = self
        if #available(iOS 15, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            self.tabBar.standardAppearance = appearance
            //      self.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.feedbackGenerator.selectionChanged()
        switch item.tag {
        case TabBarTag.my.rawValue:
            self.tabBar.barTintColor = R.color.gray100()
            if #available(iOS 15, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = R.color.gray100()
                self.tabBar.standardAppearance = appearance
                //        self.tabBar.scrollEdgeAppearance = appearance
            }
        case TabBarTag.home.rawValue, TabBarTag.category.rawValue:
            self.tabBar.barTintColor = .white
            if #available(iOS 15, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                self.tabBar.standardAppearance = appearance
                //        self.tabBar.scrollEdgeAppearance = appearance
            }
        default:
            break
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
                    self.dimView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a: 0.5)
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
            CategoryViewController.instance(),
            WriteAddressViewController.instance(delegate: self),
            MyPageViewController.instance()
        ], animated: true)
        self.tabBar.tintColor = R.color.red()
        self.tabBar.layer.borderWidth = 0
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.clipsToBounds = true
        self.tabBar.barTintColor = .white
    }
    
    private func addKakaoLinkObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.processKakaoLinkIfExisted()
        }
    }
    
    private func removeKakaoLinkObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func processKakaoLinkIfExisted() {
        let kakaoLinkStoreId = UserDefaultsUtil().getDetailLink()
        
        if kakaoLinkStoreId != 0 {
            self.goToStoreDetail(storeId: kakaoLinkStoreId)
        }
    }
    
    private func goToStoreDetail(storeId: Int) {
        self.selectedIndex = 0
        if let navigationVC = self.viewControllers?[0] as? UINavigationController,
           let homeVC = navigationVC.topViewController as? HomeVC {
            homeVC.coordinator?.goToDetail(storeId: storeId)
        }
    }
    
    private func checkIfBannerExisted() {
        PopupService().fetchPopups(position: .splash)
            .map { $0.map { Popup.init(response: $0)} }
            .subscribe(
                onNext: { [weak self] popups in
                    if !popups.isEmpty {
                        if let isDisable
                            = UserDefaultsUtil.getEventDisableToday(id: popups[0].id) {
                            if isDisable != DateUtils.todayString() {
                                // 다시보기 설정한 날짜가 오늘이 아니라면 팝업띄우기
                                self?.present(
                                    PopupViewController.instance(popup: popups[0]),
                                    animated: false
                                )
                            }
                        } else {
                            self?.present(
                                PopupViewController.instance(popup: popups[0]),
                                animated: false
                            )
                        }
                    }
                })
            .disposed(by: self.disposeBag)
    }
}

extension TabBarVC: WriteAddressDelegate {
    func onWriteSuccess(storeId: Int) {
        self.selectedIndex = 0
        if let navigationVC = self.viewControllers?[0] as? UINavigationController,
           let homeVC = navigationVC.viewControllers[0] as? HomeVC {
            navigationVC.popToRootViewController(animated: false)
            homeVC.fetchStoresFromCurrentLocation()
            homeVC.coordinator?.goToDetail(storeId: storeId)
        }
    }
}

extension TabBarVC: UITabBarControllerDelegate {
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        if let navigationVC = viewController as? UINavigationController {
            if navigationVC.topViewController is WriteAddressViewController {
                let writeVC = WriteAddressViewController.instance(delegate: self)
                
                self.present(writeVC, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
}
