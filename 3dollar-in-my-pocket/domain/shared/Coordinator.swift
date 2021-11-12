//
//  Coordinator.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/08/26.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

protocol Coordinator {
  var presenter: BaseVC { get }
  
  func popup()
  func dismiss()
  func showRootDim(isShow: Bool)
  func showErrorAlert(error: Error)
}

extension Coordinator where Self: BaseVC {
  
  var presenter: BaseVC {
    return self
  }
  
  func popup() {
    self.presenter.navigationController?.popViewController(animated: true)
  }
  
  func dismiss() {
    self.presenter.dismiss(animated: true, completion: nil)
  }
  
  func showRootDim(isShow: Bool) {
    self.presenter.showRootDim(isShow: isShow)
  }
  
  func showErrorAlert(error: Error) {
    self.presenter.showErrorAlert(error: error)
  }
}
