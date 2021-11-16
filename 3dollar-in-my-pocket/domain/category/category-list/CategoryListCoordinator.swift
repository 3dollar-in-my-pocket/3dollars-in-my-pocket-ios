//
//  CategoryListCoordinator.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/15.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

protocol CategoryListCoordinator: Coordinator, AnyObject {
  
  func pushStoreDetail(storeId: Int)
}

extension CategoryListCoordinator where Self: BaseVC {
  func pushStoreDetail(storeId: Int) {
    let viewController = StoreDetailViewController.instance(storeId: storeId)
    
    self.presenter.navigationController?.pushViewController(viewController, animated: true)
  }
}
