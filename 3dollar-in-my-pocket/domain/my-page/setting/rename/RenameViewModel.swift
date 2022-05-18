//
//  RenameViewModel.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/09/17.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import RxSwift
import RxCocoa

final class RenameViewModel: BaseViewModel {
  
  struct Intput {
    let newNickname = PublishSubject<String>()
    let tapRenameButton = PublishSubject<Void>()
  }
  
  struct Output {
    let isEnableRenameButton = PublishRelay<Bool>()
    let isHiddenAlreadyExistedNickname = PublishRelay<Bool>()
    let popViewController = PublishRelay<Void>()
  }
  
  let input = Intput()
  let output = Output()
  let userService: UserServiceProtocol
  
  init(
    userService: UserServiceProtocol
  ) {
    self.userService = userService
    
    super.init()
    
    self.input.newNickname
      .map { !$0.isEmpty }
      .bind(to: self.output.isEnableRenameButton)
      .disposed(by: self.disposeBag)
    
    self.input.tapRenameButton
      .withLatestFrom(self.input.newNickname)
      .do(onNext: { [weak self] _ in
        self?.output.isHiddenAlreadyExistedNickname.accept(true)
      })
      .bind(onNext: self.changeNickname(name:))
      .disposed(by: self.disposeBag)
  }
  
  private func changeNickname(name: String) {
    self.showLoading.accept(true)
    self.userService.changeNickname(name: name)
      .map { _ in Void() }
      .subscribe(
        onNext: { [weak self] in
            self?.showLoading.accept(false)
            self?.output.popViewController.accept(())
        },
        onError: { [weak self] error in
            self?.handleNicknameError(error: error)
        })
      .disposed(by: self.disposeBag)
  }
  
  private func handleNicknameError(error: Error) {
    self.showLoading.accept(false)
    if let changeNicknameError = error as? ChangeNicknameError {
      switch changeNicknameError {
      case .alreadyExistedNickname:
        self.output.isHiddenAlreadyExistedNickname.accept(false)
      case .badRequest:
        let alertContent = AlertContent(
          title: nil,
          message: changeNicknameError.errorDescription
        )
        
        self.showSystemAlert.accept(alertContent)
      }
    } else {
      self.showErrorAlert.accept(error)
    }
  }
}
