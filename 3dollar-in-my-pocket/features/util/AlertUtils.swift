import UIKit

struct AlertUtils {
    
    static func show(title: String? = nil, message: String? = nil) {
        let okAction = UIAlertAction(title: "확인", style: .default)
        
        show(title: nil, message: message, [okAction])
    }
    
    static func showWithCancel(title: String? = nil, message: String? = nil) {
        let okAction = UIAlertAction(title: "확인", style: .default)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        show(title: title, message: message, [okAction, cancelAction])
    }
    
    static func show(title: String?, message: String?, _ actions: [UIAlertAction]) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
            let rootVC = sceneDelegate.window?.rootViewController {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            for action in actions {
                controller.addAction(action)
            }
            rootVC.present(controller, animated: true)
        }
    }
}


