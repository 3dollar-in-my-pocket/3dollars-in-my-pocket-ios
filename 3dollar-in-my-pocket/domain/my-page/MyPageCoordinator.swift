//
//  MyPageCoordinator.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/08/26.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

protocol MyPageCoordinator: Coordinator, AnyObject {
  func goToSetting()
    
  func goToTotalRegisteredStore()
    
  func goToMyReview()
    
  func goToStoreDetail(storeId: Int)
    
}

extension MyPageCoordinator {
  func goToSetting() {
    let viewController = SettingVC.instance()
    
    self.presenter.navigationController?.pushViewController(viewController, animated: true)
  }
  
  func goToTotalRegisteredStore() {
    let viewController = RegisteredStoreViewController.instance()
    
    self.presenter.navigationController?.pushViewController(viewController, animated: true)
  }
  
  func goToMyReview() {
    let viewController = MyReviewViewController.instance()
    
    self.presenter.navigationController?.pushViewController(viewController, animated: true)
  }
  
  func goToStoreDetail(storeId: Int) {
    let viewController = StoreDetailViewController.instance(storeId: storeId)
    
    self.presenter.navigationController?.pushViewController(viewController, animated: true)
  }
}
