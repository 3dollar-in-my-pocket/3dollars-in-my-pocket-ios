//
//  Coordinator.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/08/26.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

protocol Coordinator {
  associatedtype Presenter: UIViewController
  
  var presenter: Presenter { get }
  
  init(presenter: Presenter)
}

extension Coordinator {
  init(presenter: Presenter) {
    self.init(presenter: presenter)
  }
}
