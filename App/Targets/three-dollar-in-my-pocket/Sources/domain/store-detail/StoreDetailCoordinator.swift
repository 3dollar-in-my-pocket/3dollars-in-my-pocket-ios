import UIKit

import PermissionsKit
import PhotoLibraryPermission
import CameraPermission
import KakaoSDKShare
import KakaoSDKTemplate

protocol StoreDetailCoordinator: BaseCoordinator, AnyObject {
    func showDeleteModal(storeId: Int)
    func goToModify(store: Store)
    func showReviewModal(storeId: Int, review: Review?)
    func showCamera()
    func showRegisterPhoto(storeId: Int)
    func showPhotoDetail(storeId: Int, index: Int, photos: [Image])
    func goToPhotoList(storeId: Int)
    func showMoreActionSheet(
        review: Review,
        onTapModify: @escaping (() -> Void),
        onTapDelete: @escaping (() -> Void)
    )
    func showPictureActionSheet(storeId: Int)
    func showVisit(store: Store)
    func showVisitHistories(visitHistories: [VisitHistory])
    func shareToKakao(store: Store)
    func showNotFoundError(message: String)
    func showPermissionDeniedAlert()
}

extension StoreDetailCoordinator where Self: StoreDetailViewController {
    func showDeleteModal(storeId: Int) {
        let viewController = DeleteModalViewController.instance(storeId: storeId).then {
            $0.deleagete = self
        }
        
        self.presenter.tabBarController?.present(
            viewController,
            animated: true,
            completion: nil
        )
    }
    
    func goToModify(store: Store) {
//        let modifyVC = ModifyVC.instance(store: store)
//        
//        self.presenter.navigationController?.pushViewController(modifyVC, animated: true)
    }
    
    func showReviewModal(storeId: Int, review: Review? = nil) {
        let viewController = ReviewModalViewController.instance(
            storeId: storeId,
            review: review
        )
        
        self.presenter.tabBarController?.present(viewController, animated: true, completion: nil)
    }
    
    func showCamera() {
        let imagePicker = UIImagePickerController().then {
            $0.delegate = self
            $0.sourceType = .camera
            $0.cameraCaptureMode = .photo
        }
        
        self.presenter.tabBarController?.present(
            imagePicker,
            animated: true
        )
    }
    
    func showRegisterPhoto(storeId: Int) {
        let viewController = RegisterPhotoViewController.instance(storeId: storeId).then {
            $0.delegate = self as? RegisterPhotoDelegate
        }
        
        self.presenter.tabBarController?.present(viewController, animated: true, completion: nil)
    }
    
    func showPhotoDetail(storeId: Int, index: Int, photos: [Image]) {
        let photoDetailVC = PhotoDetailViewController.instance(
            storeId: storeId,
            index: index,
            photos: photos
        )
        
        self.presenter.tabBarController?.present(photoDetailVC, animated: true, completion: nil)
    }
    
    func goToPhotoList(storeId: Int) {
        let viewController = PhotoListViewController.instance(storeid: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showMoreActionSheet(
        review: Review,
        onTapModify: @escaping (() -> Void),
        onTapDelete: @escaping (() -> Void)
    ) {
        let alertController = UIAlertController(
            title: nil,
            message: "옵션",
            preferredStyle: .actionSheet
        )
        let modifyAction = UIAlertAction(
            title: "store_detail_modify_review".localized,
            style: .default
        ) { _ in
            onTapModify()
        }
        let deleteAction = UIAlertAction(
            title: "store_detail_delete_review".localized,
            style: .destructive
        ) { _ in
            onTapDelete()
        }
        let cancelAction = UIAlertAction(
            title: "store_detail_cancel".localized,
            style: .cancel
        ) { _ in }
        
        alertController.addAction(deleteAction)
        alertController.addAction(modifyAction)
        alertController.addAction(cancelAction)
        self.presenter.present(alertController, animated: true, completion: nil)
    }
    
    func showPictureActionSheet(storeId: Int) {
        let alert = UIAlertController(
            title: "store_detail_register_photo".localized,
            message: nil,
            preferredStyle: .actionSheet
        )
        let libraryAction = UIAlertAction(
            title: "store_detail_album".localized,
            style: .default
        ) { _ in
            if Permission.photoLibrary.authorized {
                self.showRegisterPhoto(storeId: storeId)
            } else {
                Permission.photoLibrary.request { [weak self] in
                    if Permission.photoLibrary.authorized {
                        self?.reactor?.action.onNext(.tapAddPhoto)
                    } else {
                        self?.showPermissionDeniedAlert()
                    }
                    
                }
            }
        }
        let cameraAction = UIAlertAction(
            title: "store_detail_camera".localized,
            style: .default
        ) { _ in
            if Permission.camera.authorized {
                self.showCamera()
            } else {
                Permission.camera.request { [weak self] in
                    if Permission.camera.authorized {
                        self?.showCamera()
                    } else {
                        self?.showPermissionDeniedAlert()
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(
            title: "store_detail_cancel".localized,
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(libraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        self.presenter.present(alert, animated: true)
    }
    
    func showVisit(store: Store) {
        let viewController = VisitViewController.instance(store: store)
        
        self.presenter.present(viewController, animated: true, completion: nil)
    }
    
    func showVisitHistories(visitHistories: [VisitHistory]) {
        let viewController = VisitHistoryViewController.instance(visitHistories: visitHistories)
        
        self.presenter.navigationController?.parent?.present(
            viewController,
            animated: true,
            completion: nil
        )
    }
    
    func shareToKakao(store: Store) {
        let urlString =
        "https://map.kakao.com/link/map/\(store.storeName),\(store.latitude),\(store.longitude)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let webURL = URL(string: urlString)
        let link = Link(
            webUrl: webURL,
            mobileWebUrl: webURL,
            androidExecutionParams: [
                "storeId": String(store.id),
                "storeType": "streetFood"
            ],
            iosExecutionParams: [
                "storeId": String(store.id),
                "storeType": "streetFood"
            ]
        )
        let content = Content(
            title: "store_detail_share_title".localized,
            imageUrl: URL(string: "https://storage.threedollars.co.kr/share/share-with-kakao.png")!,
            imageWidth: 500,
            imageHeight: 500,
            description: "store_detail_share_description".localized,
            link: link
        )
        let feedTemplate = FeedTemplate(
            content: content,
            social: nil,
            buttonTitle: nil,
            buttons: [Button(title: "store_detail_share_button".localized, link: link)]
        )
        
        ShareApi.shared.shareDefault(templatable: feedTemplate) { linkResult, error in
            if let error = error {
                self.showErrorAlert(error: error)
            } else {
                if let linkResult = linkResult {
                    UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    func showNotFoundError(message: String) {
        AlertUtils.showWithAction(
            viewController: self,
            message: message
        ) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showPermissionDeniedAlert() {
        AlertUtils.showWithCancel(
            viewController: self,
            title: "permission_denied_title".localized,
            message: "permission_denied_description".localized,
            okButtonTitle: "permission_setting_button".localized
        ) {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
}
