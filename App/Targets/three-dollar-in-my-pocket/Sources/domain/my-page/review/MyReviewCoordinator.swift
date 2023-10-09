//
//  MyReviewCoordinator.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/12/09.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

protocol MyReviewCoordinator: Coordinator, AnyObject {
    func goToStoreDetail(storeId: Int)
    
    func showMoreActionSheet(row: Int, onTapDelete: @escaping () -> Void)
}

extension MyReviewCoordinator {
    func goToStoreDetail(storeId: Int) {
//        let viewController = StoreDetailViewController.instance(storeId: storeId)
//        
//        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showMoreActionSheet(row: Int, onTapDelete: @escaping () -> Void) {
        let alertController = UIAlertController(
            title: nil,
            message: "옵션",
            preferredStyle: .actionSheet
        )
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
        alertController.addAction(cancelAction)
        self.presenter.present(alertController, animated: true, completion: nil)
    }
}
