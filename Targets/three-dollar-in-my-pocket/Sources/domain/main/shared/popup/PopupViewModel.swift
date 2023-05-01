import UIKit

import RxSwift
import RxCocoa

final class PopupViewModel: BaseViewModel {
    
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
        let tapBannerButton = PublishSubject<Void>()
        let tapDisableButton = PublishSubject<Void>()
    }
    
    struct Output {
        let advertisement = PublishRelay<Advertisement>()
        let dismiss = PublishRelay<Void>()
    }
    
    struct Model {
        let advertisement: Advertisement
    }
    
    let input = Input()
    let output = Output()
    let model: Model
    let userDefaults: UserDefaultsUtil
    
    
    init(advertisement: Advertisement, userDefaults: UserDefaultsUtil) {
        self.model = Model(advertisement: advertisement)
        self.userDefaults = userDefaults
        
        super.init()
    }
    
    override func bind() {
        self.input.viewDidLoad
            .compactMap { [weak self] in
                self?.model.advertisement
            }
            .bind(to: self.output.advertisement)
            .disposed(by: self.disposeBag)
        
        self.input.tapBannerButton
            .compactMap { [weak self] in
                self?.model.advertisement
            }
            .bind(onNext: { [weak self] advertisement in
                AnalyticsManager.shared.logEvent(
                    event: .splashPopupClicked(id: String(advertisement.id)),
                    screen: .splashPopup
                )
                self?.openEventURL(advertisement: advertisement)
            })
            .disposed(by: self.disposeBag)
        
        self.input.tapDisableButton
            .compactMap { [weak self] in
                self?.model.advertisement
            }
            .bind(onNext: { [weak self] advertisement in
                self?.setDisableToday(advertisement: advertisement)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func openEventURL(advertisement: Advertisement) {
        guard let url = URL(string: advertisement.linkUrl),
              UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        self.output.dismiss.accept(())
    }
    
    private func setDisableToday(advertisement: Advertisement) {
        self.userDefaults.setEventDisableToday(id: advertisement.id)
        self.output.dismiss.accept(())
    }
}
