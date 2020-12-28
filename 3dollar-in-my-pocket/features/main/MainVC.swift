import UIKit

class MainVC: BaseVC {
  
  private lazy var mainView = MainView(frame: self.view.frame)
  
  private var controllers: [BaseVC] = []
  
  private var previousIndex = 0
  
  private var selectedIndex = 0
  
  
  deinit {
    self.removeKakaoLinkObserver()
  }
  
  static func instance() -> UINavigationController {
    let controller = MainVC(nibName: nil, bundle: nil)
    
    return UINavigationController(rootViewController: controller)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.isNavigationBarHidden = true
    navigationController?.interactivePopGestureRecognizer?.delegate = nil
    view = mainView
    
    let homeVC = HomeVC.instance().then {
      $0.delegate = self
    }
    let writingVC = WritingVC.instance().then {
      $0.deleagte = self
    }
    let myPageVC = MyPageVC.instance().then {
      $0.delegate = self
    }
    
    controllers = [homeVC, writingVC, myPageVC]
    tapChange(index: 0)
    mainView.homeBtn.isSelected = true
    
    getEvents()
    self.addKakaoLinkObserver()
    self.processKakaoLinkIfExisted()
  }
  
  override func bindViewModel() {
    mainView.homeBtn.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .navigation_home_button_clicked, className: MainVC.self)
      })
      .bind {
      self.tapChange(index: 0)
    }.disposed(by: disposeBag)
    
    mainView.myPageBtn.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .navigation_my_page_button_clicked, className: MainVC.self)
      })
      .bind {
      self.tapChange(index: 2)
    }.disposed(by: disposeBag)
    
    mainView.writingBtn.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .navigation_register_button_clicked, className: MainVC.self)
      })
      .bind { [weak self] in
      if let vc = self {
        let writingVC = WritingVC.instance().then {
          $0.deleagte = self
        }
        vc.present(writingVC, animated: true, completion: nil)
      }
    }.disposed(by: disposeBag)
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
  
  private func tapChange(index: Int) {
    previousIndex = selectedIndex
    selectedIndex = index
    
    let previousVC = controllers[previousIndex]
    
    previousVC.willMove(toParent: nil)
    previousVC.view.removeFromSuperview()
    previousVC.removeFromParent()
    
    let vc = controllers[selectedIndex]
    
    vc.didMove(toParent: self)
    self.addChild(vc)
    self.view.addSubview(vc.view)
    
    self.view.bringSubviewToFront(mainView.stackBg)
    self.view.bringSubviewToFront(mainView.stackView)
    self.mainView.selectBtn(index: index)
    DispatchQueue.main.async {
      UIView.animate(withDuration: 0.3) { [weak self] in
        self?.setNeedsStatusBarAppearanceUpdate()
      }
    }
  }
  
  private func getEvents() {
    EventService.getEvents { [weak self] (events) in
      if !events.isEmpty {
        if let isDisable = UserDefaultsUtil.getEventDisableToday(id: events[0].id!) {
          if isDisable != DateUtils.todayString() { // 다시보기 설정한 날짜가 오늘이 아니라면 팝업띄우기
            self?.present(PopupVC.instance(event: events[0]), animated: false)
          }
        } else {
          self?.present(PopupVC.instance(event: events[0]), animated: false)
        }
      }
    }
  }
  
  private func processKakaoLinkIfExisted() {
    let kakaoLinkStoreId = UserDefaultsUtil().getDetailLink()
    
    if kakaoLinkStoreId != 0 {
      self.goToDetail(storeId: kakaoLinkStoreId)
    }
  }
  
  private func goToDetail(storeId: Int) {
    self.navigationController?.pushViewController(DetailVC.instance(storeId: storeId), animated: true)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return selectedIndex == 2 ? .lightContent : .default
  }
}

extension MainVC: HomeDelegate {
  func onTapCategory(category: StoreCategory) {
    self.navigationController?.pushViewController(CategoryListVC.instance(category: category), animated: true)
  }
  
  func didDragMap() {
    self.mainView.hideTabBar()
  }
  
  func endDragMap() {
    self.mainView.showTabBar()
  }
}

extension MainVC: WritingDelegate {
  func onWriteSuccess(storeId: Int) {
    for controller in self.controllers {
      if controller is HomeVC {
        (controller as! HomeVC).onSuccessWrite()
      }
    }
    self.navigationController?.pushViewController(DetailVC.instance(storeId: storeId), animated: true)
  }
}

extension MainVC: MyPageDelegate {
  func onScrollStart() {
    self.mainView.hideTabBar()
  }
  
  func onScrollEnd() {
    self.mainView.showTabBar()
  }
}
