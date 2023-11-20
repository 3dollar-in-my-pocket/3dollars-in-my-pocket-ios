import UIKit

public struct AlertUtils {
    public static func showImagePicker(controller: UIViewController, picker: UIImagePickerController) {
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
    
    public static func showWithAction(
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
    
    public static func showWithCancel(
        viewController: UIViewController,
        title: String? = nil,
        message: String? = nil,
        okButtonTitle: String = "확인",
        onTapOk: @escaping () -> Void
    ) {
        let okAction = UIAlertAction(title: okButtonTitle, style: .default) { _ in
            onTapOk()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        show(viewController: viewController, title: title, message: message, [okAction, cancelAction])
    }
    
    public static func show(
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
