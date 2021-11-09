//
//  VisitViewController.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/09.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

final class VisitViewController: BaseVC, VisitCoordinator {
  private let visitView = VisitView()
  private weak var coordinator: VisitCoordinator?
  
  static func instance() -> VisitViewController {
    return VisitViewController(nibName: nil, bundle: nil).then {
      $0.modalPresentationStyle = .fullScreen
    }
  }
  
  override func loadView() {
    self.view = self.visitView
  }
  
  override func viewDidLoad() {
    self.coordinator = self
  }
  
  override func bindEvent() {
    self.visitView.closeButton.rx.tap
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.coordinator?.dismiss()
      })
      .disposed(by: self.disposeBag)
  }
}
