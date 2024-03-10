import UIKit

struct AlertUtils {
    @available(*, deprecated, message: "사라질 예정입니다.")
    static func showWithAction(title: String? = nil, message: String? = nil, handler: @escaping ((UIAlertAction) -> Void)) {
        let action = UIAlertAction.init(title: "확인", style: .default, handler: handler)
        show(title: title, message: message, [action])
    }
    
    @available(*, deprecated, message: "사라질 예정입니다.")
    static func show(parentController: UIViewController? = nil, title: String?, message: String?, _ actions: [UIAlertAction]) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            controller.addAction(action)
        }
        if parentController != nil {
            parentController?.present(controller, animated: true)
        } else {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let rootVC = sceneDelegate.window?.rootViewController {
                
                rootVC.present(controller, animated: true)
            }
        }
    }
    
    @available(*, deprecated, message: "사라질 예정입니다.")
    static func showWithAction(
        controller: UIViewController,
        title: String? = nil,
        message: String? = nil,
        onTapOk: @escaping (() -> Void)) {
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                onTapOk()
            }
            
            show(controller: controller, title: title, message: message, [okAction])
        }
    
    @available(*, deprecated, message: "사라질 예정입니다.")
    static func show(
        controller: UIViewController,
        title: String?,
        message: String?
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        
        alertController.addAction(okAction)
        controller.present(alertController, animated: true)
    }
    
    @available(*, deprecated, message: "사라질 예정입니다.")
    static func show(
        controller: UIViewController,
        title: String?,
        message: String?,
        _ actions: [UIAlertAction]
    ) {
        let alrtController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alrtController.addAction(action)
        }
        controller.present(alrtController, animated: true)
    }
    
    static func showWithAction(
        viewController: UIViewController,
        title: String? = nil,
        message: String? = nil,
        okbuttonTitle: String = "확인",
        onTapOk: (() -> Void)?
    ) {
        let okAction = UIAlertAction(title: okbuttonTitle, style: .default) { _ in
            onTapOk?()
        }
        
        Self.show(viewController: viewController, title: title, message: message, [okAction])
    }
    
    static func show(
        viewController: UIViewController,
        title: String?,
        message: String?,
        _ actions: [UIAlertAction]
    ) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            controller.addAction(action)
        }
        
        viewController.present(controller, animated: true)
    }
}
