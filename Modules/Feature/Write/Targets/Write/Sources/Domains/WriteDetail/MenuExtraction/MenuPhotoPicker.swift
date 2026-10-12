import AVFoundation
import UIKit

import Common
import DesignSystem
import StoreInterface

final class MenuPhotoPicker: NSObject {
    private weak var presenter: UIViewController?
    private var onPicked: ((Data) -> Void)?

    func present(from presenter: UIViewController, onPicked: @escaping (Data) -> Void) {
        self.presenter = presenter
        self.onPicked = onPicked

        let viewController = MenuPhotoSelectViewController(
            viewModel: MenuPhotoSelectViewModel(),
            onTapAlbum: { [weak self] in
                self?.presentAlbum()
            },
            onTapCamera: { [weak self] in
                self?.presentCamera()
            }
        )
        presenter.present(viewController, animated: true)
    }

    private func presentAlbum() {
        let config = UploadPhotoConfig(
            storeId: 0,
            shouldDeferUpload: true,
            onSelectedPhotos: { [weak self] photos in
                guard let photo = photos.first else { return }
                self?.onPicked?(photo)
            },
            limitOfPhoto: 1
        )
        let viewController = Environment.storeInterface.getUploadPhotoViewController(config: config)
        presenter?.present(viewController, animated: true)
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            ToastManager.shared.show(message: Strings.MenuPhotoSelect.cameraUnavailable)
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            presentCameraPermissionAlert()
        default:
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .camera
            pickerController.delegate = self
            presenter?.present(pickerController, animated: true)
        }
    }

    private func presentCameraPermissionAlert() {
        guard let presenter else { return }
        AlertUtils.showWithCancel(
            viewController: presenter,
            message: Strings.MenuPhotoSelect.cameraPermission,
            okButtonTitle: Strings.MenuPhotoSelect.openSetting
        ) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
    }
}

extension MenuPhotoPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true) { [weak self] in
            guard let image else { return }
            Task { @MainActor [weak self] in
                let photo = await Task.detached(priority: .userInitiated) {
                    ImageUtils.dataArrayFromImages(photos: [image]).first
                }.value
                guard let photo else { return }
                self?.onPicked?(photo)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
