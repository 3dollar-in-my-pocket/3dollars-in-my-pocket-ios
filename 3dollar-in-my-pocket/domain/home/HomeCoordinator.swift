//
//  HomeCoordinator.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/09/25.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

final class HomeCoordinator: Coordinator {
  let presenter: HomeVC
  
  required init(presenter: HomeVC) {
    self.presenter = presenter
  }
  
  func goToDetail(storeId: Int) {
    let storeDetailVC = StoreDetailViewController.instance(storeId: storeId).then {
      $0.delegate = self.presenter
    }
    
    self.presenter.navigationController?.pushViewController(
      storeDetailVC,
      animated: true
    )
  }
  
  func showDenyAlert() {
    AlertUtils.showWithCancel(
      controller: self.presenter,
      title: "location_deny_title".localized,
      message: "location_deny_description".localized,
      okButtonTitle: "설정",
      onTapOk: self.goToAppSetting
    )
  }
  
  func goToAppSetting() {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
      return
    }
    
    if UIApplication.shared.canOpenURL(settingsUrl) {
      UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }
  }
  
  func goToToss() {
    let tossScheme = Bundle.main.object(forInfoDictionaryKey: "Toss scheme") as? String ?? ""
    guard let url = URL(string: tossScheme) else { return }
    
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
  
  func showSearchAddress() {
    let searchAddressVC = SearchAddressVC.instacne().then {
      $0.transitioningDelegate = self.presenter
      $0.delegate = self.presenter
    }
    
    self.presenter.tabBarController?.present(searchAddressVC, animated: true, completion: nil)
  }
}
