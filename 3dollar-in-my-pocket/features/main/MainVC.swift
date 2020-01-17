import UIKit

class MainVC: BaseVC {
    
    private lazy var mainView = MainView(frame: self.view.frame)
    
    private var controllers: [BaseVC] = []
    
    private var previousIndex = 0
    
    private var selectedIndex = 0
    
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
        
        controllers = [homeVC, writingVC, MyPageVC.instance(),]
        tapChange(index: 0)
        mainView.homeBtn.isSelected = true
    }
    
    override func bindViewModel() {
        mainView.homeBtn.rx.tap.bind {
            self.tapChange(index: 0)
        }.disposed(by: disposeBag)
        
        mainView.myPageBtn.rx.tap.bind {
            self.tapChange(index: 2)
        }.disposed(by: disposeBag)
        
        mainView.writingBtn.rx.tap.bind {
            let writingVC = WritingVC.instance().then {
                $0.deleagte = self
            }
            self.present(writingVC, animated: true, completion: nil)
        }.disposed(by: disposeBag)
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return selectedIndex == 2 ? .lightContent : .default
    }
}

extension MainVC: HomeDelegate {
    func onTapCategory() {
        self.navigationController?.pushViewController(CategoryListVC.instance(), animated: true)
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
        self.navigationController?.pushViewController(DetailVC.instance(storeId: storeId), animated: true)
    }
}
