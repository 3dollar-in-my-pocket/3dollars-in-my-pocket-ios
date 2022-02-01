import RxSwift
import RxCocoa

final class PopupViewModel: BaseViewModel {
    
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
        let tapBannerButton = PublishSubject<Void>()
        let tapDisableButton = PublishSubject<Void>()
    }
    
    struct Output {
        let popup = PublishRelay<Popup>()
        let dismiss = PublishRelay<Void>()
    }
    
    struct Model {
        let popup: Popup
    }
    
    let input = Input()
    let output = Output()
    let model: Model
    let userDefaults: UserDefaultsUtil
    
    
    init(event: Popup, userDefaults: UserDefaultsUtil) {
        self.model = Model(popup: event)
        self.userDefaults = userDefaults
        
        super.init()
    }
    
    override func bind() {
        self.input.viewDidLoad
            .compactMap { [weak self] in
                self?.model.popup
            }
            .bind(to: self.output.popup)
            .disposed(by: self.disposeBag)
        
        self.input.tapBannerButton
            .compactMap { [weak self] in
                self?.model.popup
            }
            .bind(onNext: { [weak self] popup in
                GA.shared.logEvent(event: .tap_splash_popup, page: .splash_popup)
                self?.openEventURL(popup: popup)
            })
            .disposed(by: self.disposeBag)
        
        self.input.tapDisableButton
            .compactMap { [weak self] in
                self?.model.popup
            }
            .bind(onNext: { [weak self] event in
                self?.setDisableToday(event: event)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func openEventURL(popup: Popup) {
        guard let url = URL(string: popup.linkUrl),
              UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        self.output.dismiss.accept(())
    }
    
    private func setDisableToday(event: Popup) {
        self.userDefaults.setEventDisableToday(id: event.id)
        self.output.dismiss.accept(())
    }
}
