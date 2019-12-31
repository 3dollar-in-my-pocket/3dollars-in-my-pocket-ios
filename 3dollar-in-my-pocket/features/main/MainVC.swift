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
        
        let homeVc = HomeVC.instance()
        
        homeVc.delegate = self
        controllers = [MyPageVC.instance(), homeVc, WritingVC.instance()]
        tapChange(index: 1)
    }
    
    override func bindViewModel() {
        mainView.homeBtn.rx.tap.bind {
            self.tapChange(index: 1)
        }.disposed(by: disposeBag)
        
        mainView.myPageBtn.rx.tap.bind {
            self.tapChange(index: 0)
        }.disposed(by: disposeBag)
        
        mainView.writingBtn.rx.tap.bind {
            self.present(WritingVC.instance(), animated: true, completion: nil)
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
    }
}

extension MainVC: HomeDelegate {
    func onTapCategory() {
        self.navigationController?.pushViewController(CategoryListVC.instance(), animated: true)
    }
}
