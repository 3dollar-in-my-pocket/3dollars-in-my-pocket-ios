//
//  VisitCoordinator.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/09.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

protocol VisitCoordinator: Coordinator, AnyObject {
  func dismissWithSuccessAlert()
}

extension VisitCoordinator where Self: BaseVC {
  func dismissWithSuccessAlert() {
    AlertUtils.showWithAction(
      controller: self,
      title: "인증 성공했습니다!",
      message: nil) { [weak self] in
      self?.dismiss()
    }
  }
}
