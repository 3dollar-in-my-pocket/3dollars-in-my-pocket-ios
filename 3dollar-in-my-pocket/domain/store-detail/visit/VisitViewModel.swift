//
//  VisitViewModel.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/09.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import RxSwift
import RxCocoa

final class VisitViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  var model: Model
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    let store = PublishRelay<Store>()
  }
  
  struct Model {
    let store: Store
  }
  
  init(
    store: Store
  ) {
    self.model = Model(store: store)
    
    super.init()
  }
  
  override func bind() {
    self.input.viewDidLoad
      .compactMap { [weak self] in
        self?.model.store
      }
      .bind(to: self.output.store)
      .disposed(by: self.disposeBag)
  }
}

