import UIKit

struct AlertUtils {
  
  static func show(controller: UIViewController? = nil, title: String? = nil, message: String? = nil) {
    let okAction = UIAlertAction(title: "확인", style: .default)
    
    show(parentController: controller, title: title, message: message, [okAction])
  }
  
  static func showWithCancel(controller: UIViewController? = nil, title: String? = nil, message: String? = nil) {
    let okAction = UIAlertAction(title: "확인", style: .default)
    let cancelAction = UIAlertAction(title: "취소", style: .cancel)
    
    show(parentController: controller, title: title, message: message, [okAction, cancelAction])
  }
  
  static func showWithAction(title: String? = nil, message: String? = nil, handler: @escaping ((UIAlertAction) -> Void)) {
    let action = UIAlertAction.init(title: "확인", style: .default, handler: handler)
    show(title: title, message: message, [action])
  }
  
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
  
  static func showWithAction(
    controller: UIViewController,
    title: String? = nil,
    message: String? = nil,
    onTapOk: @escaping (() -> Void)) {
    let okAction = UIAlertAction(title: "확인", style: .default) { action in
      onTapOk()
    }
    
    show(controller: controller, title: title, message: message, [okAction])
    
  }
  
  static func showWithCancel(
    controller: UIViewController,
    title: String? = nil,
    message: String? = nil,
    onTapOk: @escaping () -> Void
  ) {
    let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
      onTapOk()
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel)
    
    show(controller: controller, title: title, message: message, [okAction, cancelAction])
  }
  
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
  
  static func showImagePicker(controller: UIViewController, picker: UIImagePickerController) {
    let alert = UIAlertController(title: "이미지 불러오기", message: nil, preferredStyle: .actionSheet)
    let libraryAction = UIAlertAction(title: "앨범", style: .default) { ( _) in
      picker.sourceType = .photoLibrary
      controller.present(picker, animated: true)
    }
    let cameraAction = UIAlertAction(title: "카메라", style: .default) { (_ ) in
      picker.sourceType = .camera
      controller.present(picker, animated: true)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    alert.addAction(libraryAction)
    alert.addAction(cameraAction)
    alert.addAction(cancelAction)
    controller.present(alert, animated: true)
  }
}


