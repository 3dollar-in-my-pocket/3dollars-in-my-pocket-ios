import UIKit

class PopupVC: BaseVC {
    
    private lazy var popupView = PopupView.init(frame: self.view.frame)
    var event: Event!
    
    static func instance(event: Event) -> PopupVC {
        return PopupVC.init(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .fullScreen
            $0.event = event
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = popupView
        popupView.bind(event: event)
    }
    
    override func bindViewModel() {
        popupView.bannerBtn.rx.tap.bind { [weak self] _ in
            if let vc = self {
                guard let url = URL(string: vc.event.url), UIApplication.shared.canOpenURL(url) else { return }
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                vc.dismiss(animated: false)
            }
        }.disposed(by: disposeBag)
        
        popupView.cancelBtn.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        popupView.disableTodayBtn.rx.tap.bind { [weak self] in
            if let vc = self {
                UserDefaultsUtil.setEventDisableToday(id: vc.event.id!)
                vc.dismiss(animated: false)
            }
        }.disposed(by: disposeBag)
    }
}
