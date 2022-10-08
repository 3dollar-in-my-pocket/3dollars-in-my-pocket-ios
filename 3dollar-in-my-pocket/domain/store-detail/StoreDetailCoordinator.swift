//
//  StoreDetailCoordinator.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/10/25.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit
import Base
import SPPermissions

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
}

extension StoreDetailCoordinator where Self: BaseViewController {
    func showDeleteModal(storeId: Int) {
        let deleteVC = DeleteModalVC.instance(storeId: storeId).then {
            $0.deleagete = self as? DeleteModalDelegate
        }
        
        self.presenter.tabBarController?.present(
            deleteVC,
            animated: true,
            completion: nil
        )
    }
    
    func goToModify(store: Store) {
        let modifyVC = ModifyVC.instance(store: store)
        
        self.presenter.navigationController?.pushViewController(modifyVC, animated: true)
    }
    
    func showReviewModal(storeId: Int, review: Review? = nil) {
        let reviewVC = ReviewModalVC.instance(storeId: storeId, review: review).then {
            $0.deleagete = self as? ReviewModalDelegate
        }
        
        self.presenter.tabBarController?.present(reviewVC, animated: true, completion: nil)
    }
    
    func showCamera() {
        let imagePicker = UIImagePickerController().then {
            $0.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            $0.sourceType = .camera
            $0.cameraCaptureMode = .photo
        }
        
        self.presenter.tabBarController?.present(
            imagePicker,
            animated: true
        )
    }
    
    func showRegisterPhoto(storeId: Int) {
        let registerPhotoVC = RegisterPhotoVC.instance(storeId: storeId).then {
            $0.delegate = self as? RegisterPhotoDelegate
        }
        
        self.presenter.tabBarController?.present(registerPhotoVC, animated: true, completion: nil)
    }
    
    func showPhotoDetail(storeId: Int, index: Int, photos: [Image]) {
        let photoDetailVC = PhotoDetailVC.instance(
            storeId: storeId,
            index: index,
            photos: photos
        ).then {
            $0.delegate = self as? PhotoDetailDelegate
        }
        
        self.presenter.tabBarController?.present(photoDetailVC, animated: true, completion: nil)
    }
    
    func goToPhotoList(storeId: Int) {
        let photoListVC = PhotoListVC.instance(storeid: storeId).then {
            $0.hidesBottomBarWhenPushed = true
        }
        
        self.presenter.navigationController?.pushViewController(photoListVC, animated: true)
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
            title: R.string.localization.store_detail_modify_review(),
            style: .default
        ) { _ in
            onTapModify()
        }
        let deleteAction = UIAlertAction(
            title: R.string.localization.store_detail_delete_review(),
            style: .destructive
        ) { _ in
            onTapDelete()
        }
        let cancelAction = UIAlertAction(
            title: R.string.localization.store_detail_cancel(),
            style: .cancel
        ) { _ in }
        
        alertController.addAction(deleteAction)
        alertController.addAction(modifyAction)
        alertController.addAction(cancelAction)
        self.presenter.present(alertController, animated: true, completion: nil)
    }
    
    func showPictureActionSheet(storeId: Int) {
        let alert = UIAlertController(
            title: R.string.localization.store_detail_register_photo(),
            message: nil,
            preferredStyle: .actionSheet
        )
        let libraryAction = UIAlertAction(
            title: "store_detail_album".localized,
            style: .default
        ) { _ in
            if SPPermission.photoLibrary.isAuthorized {
                self.showRegisterPhoto(storeId: storeId)
            } else {
                let controller = SPPermissions.native([.photoLibrary])
                
                controller.delegate = self as? SPPermissionsDelegate
                controller.present(on: self)
            }
        }
        let cameraAction = UIAlertAction(
            title: "store_detail_camera".localized,
            style: .default
        ) { _ in
            if SPPermission.camera.isAuthorized {
                self.showCamera()
            } else {
                let controller = SPPermissions.native([.camera])
                
                controller.delegate = self as? SPPermissionsDelegate
                controller.present(on: self)
            }
        }
        let cancelAction = UIAlertAction(
            title: R.string.localization.store_detail_cancel(),
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
        
        viewController.delegate = self.presenter as? VisitHistoryViewControllerDelegate
        self.presenter.navigationController?.parent?.present(
            viewController,
            animated: true,
            completion: nil
        )
    }
}
