//
//  MyPageCoordinator.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/08/26.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

final class MyPageCoordinator: Coordinator {
  var presenter: MyPageVC
  
  required init(presenter: MyPageVC) {
    self.presenter = presenter
  }
  
  func goToSetting() {
    let viewController = SettingVC.instance()
    
    self.presenter.navigationController?.pushViewController(viewController, animated: true)
  }
  
  func goToTotalRegisteredStore() {
    let viewController = RegisteredVC.instance()
    
    self.presenter.navigationController?.pushViewController(viewController, animated: true)
  }
  
  func goToMyReview() {
    let viewController = MyReviewVC.instance()
    
    self.presenter.navigationController?.pushViewController(viewController, animated: true)
  }
  
  func goToStoreDetail(storeId: Int) {
    let viewController = StoreDetailVC.instance(storeId: storeId)
    
    self.presenter.navigationController?.pushViewController(viewController, animated: true)
  }
}
