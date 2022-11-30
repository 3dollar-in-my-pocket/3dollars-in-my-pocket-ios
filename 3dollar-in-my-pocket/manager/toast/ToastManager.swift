import Foundation
import UIKit

protocol ToastManagerProtocol {
    func show(message: String)
    
    func show(message: String, baseView: UIView)
}

class ToastManager: ToastManagerProtocol {
    static let shared = ToastManager()
    
    private var toastViewQueue: [ToastView] = []
    
    private var keyWindow: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    func show(message: String) {
        DispatchQueue.main.async {
            guard let window = self.keyWindow else { return }
            let toastView = ToastView().then {
                $0.alpha = 0
            }
            
            toastView.bind(message: message)
            window.addSubViews([toastView])
            toastView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(window.safeAreaLayoutGuide).offset(-42)
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                toastView.alpha = 1
            } completion: { _ in
                let timer = Timer.scheduledTimer(
                    withTimeInterval: 2,
                    repeats: false
                ) { [weak self] timer in
                    guard let self = self else { return }
                    timer.invalidate()
                    self.dismiss(toastView: toastView )
                }
            }
        }
    }
    
    func show(message: String, baseView: UIView) {
        DispatchQueue.main.async {
            guard let window = self.keyWindow else { return }
            let toastView = ToastView().then {
                $0.alpha = 0
            }
            
            toastView.bind(message: message)
            window.addSubViews([toastView])
            toastView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(baseView.snp.top).offset(-19)
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                toastView.alpha = 1
            } completion: { _ in
                let timer = Timer.scheduledTimer(
                    withTimeInterval: 2,
                    repeats: false
                ) { [weak self] timer in
                    guard let self = self else { return }
                    timer.invalidate()
                    self.dismiss(toastView: toastView )
                }
            }
        }
    }
    
    private func dismiss(toastView: ToastView) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            toastView.alpha = 0
        } completion: { _ in
            toastView.removeFromSuperview()
        }
    }
}
