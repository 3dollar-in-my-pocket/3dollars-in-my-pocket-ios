import UIKit

import RxSwift
import RxCocoa

final class FoodTruckTooltipView: BaseView {
    private let fingerImage = UIImageView().then {
        $0.image = UIImage(named: "img_tootip_finger")
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = Color.gray80
        $0.layer.cornerRadius = 12
    }
    
    private let messageLabel = UILabel().then {
        $0.font = .medium(size: 14)
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.text = "home_foodtruck_tooltip".localized
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.fingerImage,
            self.messageLabel
        ])
        self.initializeNotification()
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(self.fingerImage).offset(8)
            make.right.equalTo(self.messageLabel).offset(16)
            make.bottom.equalTo(self.messageLabel).offset(12)
        }
        
        self.fingerImage.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(8)
            make.top.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        self.messageLabel.snp.makeConstraints { make in
            make.left.equalTo(self.fingerImage.snp.right)
            make.top.equalTo(self.containerView).offset(12)
        }
        
        self.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).priority(.high)
            make.top.equalTo(self.fingerImage).priority(.high)
            make.right.equalTo(self.containerView).priority(.high)
            make.bottom.equalTo(self.containerView).priority(.high)
        }
    }
    
    func show() {
        self.isHidden = false
        UIView.transition(with: self, duration: 0.3, options: .curveEaseInOut) { [weak self] in
            self?.alpha = 1.0
        }
        UIView.transition(
            with: self,
            duration: 1,
            options: [.autoreverse, .repeat]
        ) { [weak self] in
            self?.transform = .init(translationX: 0, y: 10)
        } completion: { [weak self] _ in
            self?.transform = .identity
        }
    }
    
    func resumeAnimation() {
        if !self.isHidden {
            UIView.transition(
                with: self,
                duration: 1,
                options: [.autoreverse, .repeat]
            ) { [weak self] in
                self?.transform = .init(translationX: 0, y: 10)
            } completion: { [weak self] _ in
                self?.transform = .identity
            }
        }
    }
    
    fileprivate func hide() {
        UIView.transition(with: self, duration: 0.3, options: .curveEaseInOut) { [weak self] in
            self?.alpha = 0.0
        } completion: { [weak self] _ in
            self?.layer.removeAllAnimations()
            self?.isHidden = true
        }
    }
    
    private func initializeNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc private func didBecomeActive() {
        if !self.isHidden {
            UIView.transition(
                with: self,
                duration: 1,
                options: [.autoreverse, .repeat]
            ) { [weak self] in
                self?.transform = .init(translationX: 0, y: 10)
            } completion: { [weak self] _ in
                self?.transform = .identity
            }
        }
    }
    
    @objc private func willResignActive() {
        self.layer.removeAllAnimations()
    }
}

extension Reactive where Base: FoodTruckTooltipView {
    var isTooltipHidden: Binder<Bool> {
        return Binder(self.base) { view, isHidden in
            if isHidden {
                view.hide()
            } else {
                view.show()
            }
        }
    }
}
