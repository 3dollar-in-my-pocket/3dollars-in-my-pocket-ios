//
//  StoreVisitHistoryView.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/12.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

final class StoreVisitHistoryView: BaseView {
  
  private let titleLabel = UILabel().then {
    $0.font = .semiBold(size: 18)
    $0.textColor = .black
  }
  
  private let bedgeImage = UIImageView().then {
    $0.image = R.image.img_bedge()
  }
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
  }
  
  private let existImage = UIImageView()
  
  private let existLabel = UILabel().then {
    $0.font = .bold(size: 16)
    $0.textColor = R.color.gray30()
  }
  
  private let notExistImage = UIImageView()
  
  private let notExistLabel = UILabel().then {
    $0.font = .bold(size: 16)
    $0.textColor = R.color.gray30()
  }
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews([
      self.titleLabel,
      self.bedgeImage,
      self.containerView,
      self.existImage,
      self.existLabel,
      self.notExistImage,
      self.notExistLabel
    ])
  }
  
  override func bindConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview()
    }
    
    self.bedgeImage.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(24)
      make.width.height.equalTo(32)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.left.equalTo(self.bedgeImage.snp.right).offset(15)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
      make.height.equalTo(48)
    }
    
    self.existImage.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(10)
      make.centerY.equalTo(self.containerView)
      make.width.height.equalTo(24)
    }
    
    self.existLabel.snp.makeConstraints { make in
      make.left.equalTo(self.existImage.snp.right).offset(10)
      make.centerY.equalTo(self.existImage)
    }
    
    self.notExistImage.snp.makeConstraints { make in
      make.left.equalTo(self.containerView.snp.centerX)
      make.centerY.equalTo(self.containerView)
      make.width.height.equalTo(24)
    }
    
    self.notExistLabel.snp.makeConstraints { make in
      make.left.equalTo(self.notExistImage.snp.right).offset(10)
      make.centerY.equalTo(self.notExistImage)
    }
    
    self.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel).priority(.high)
      make.bottom.equalTo(self.containerView).priority(.high)
    }
  }
  
  func bind(visitHistories: [VisitHistory]) {
    let existedCount = visitHistories.filter { $0.type == .exists }.count
    let notExistedCount = visitHistories.filter { $0.type == .notExists }.count
    
    self.setupTitleLabel(isEmpty: visitHistories.isEmpty, count: existedCount)
    self.setupExist(count: existedCount)
    self.setupNotExist(count: notExistedCount)
  }
  
  private func setupTitleLabel(isEmpty: Bool, count: Int) {
    if isEmpty {
      let text = R.string.localization.store_detail_empty_visit_history()
      let attributedString = NSMutableAttributedString(string: text)
      let boldTextRange = (text as NSString).range(of: "방문 인증")
      
      attributedString.addAttribute(
        .font,
        value: R.font.appleSDGothicNeoEB00(size: 18) as Any,
        range: boldTextRange
      )
      self.titleLabel.attributedText = attributedString
    } else {
      let text = R.string.localization.store_detail_visit_history(count)
      let attributedString = NSMutableAttributedString(string: text)
      let boldTextRange = (text as NSString).range(of: "\(count)명")
      
      attributedString.addAttribute(
        .font,
        value: R.font.appleSDGothicNeoEB00(size: 18) as Any,
        range: boldTextRange
      )
      self.titleLabel.attributedText = attributedString
    }
  }
  
  private func setupExist(count: Int) {
    self.existImage.image = count == 0 ? R.image.img_exist_empty() : R.image.img_exist()
    self.existLabel.textColor = count == 0 ? R.color.gray30() : UIColor(r: 0, g: 198, b: 103)
    self.existLabel.text = "\(count) 명"
  }
  
  private func setupNotExist(count: Int) {
    self.notExistImage.image = count == 0 ? R.image.img_not_exist_empty() : R.image.img_not_exist()
    self.notExistLabel.textColor = count == 0 ? R.color.gray30() : R.color.red()
    self.notExistLabel.text = "\(count) 명"
  }
}
