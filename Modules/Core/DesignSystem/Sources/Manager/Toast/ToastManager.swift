import UIKit

public class ToastManager {
    public static let shared = ToastManager()
    
    private var toastViewQueue: [ToastView] = []
    
    private var keyWindow: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    public func show(message: String) {
        DispatchQueue.main.async {
            guard let window = self.keyWindow else { return }
            let toastView = ToastView()
            toastView.alpha = 0
            toastView.bind(message: message)
            toastView.translatesAutoresizingMaskIntoConstraints = false

            window.addSubview(toastView)

            toastView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            toastView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -42).isActive = true

            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                toastView.alpha = 1
            } completion: { _ in
                let _ = Timer.scheduledTimer(
                    withTimeInterval: 2,
                    repeats: false
                ) { [weak self] timer in
                    guard let self = self else { return }
                    timer.invalidate()
                    self.dismiss(toastView: toastView)
                }
            }
        }
    }
    
    public func show(message: String, baseView: UIView) {
        DispatchQueue.main.async {
            guard let window = self.keyWindow else { return }
            let toastView = ToastView()
            toastView.alpha = 0
            toastView.bind(message: message)
            toastView.translatesAutoresizingMaskIntoConstraints = false
            
            window.addSubview(toastView)
            
            toastView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            toastView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -19).isActive = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                toastView.alpha = 1
            } completion: { _ in
                let _ = Timer.scheduledTimer(
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
