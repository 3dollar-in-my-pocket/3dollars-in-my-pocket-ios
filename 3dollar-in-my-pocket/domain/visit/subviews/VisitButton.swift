//
//  VisitButton.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/12.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

final class VisitButton: UIButton {
  
  static let size = CGSize(
    width: (UIScreen.main.bounds.width - 63)/2,
    height: (UIScreen.main.bounds.width - 63)/2
  )
  
  private let stackView = UIStackView().then {
    $0.isUserInteractionEnabled = false
    $0.axis = .vertical
    $0.spacing = 4
    $0.alignment = .center
  }
  
  private let visitImage = UIImageView().then {
    $0.isUserInteractionEnabled = false
  }
  
  private let subjectLabel = UILabel().then {
    $0.font = .semiBold(size: 16)
    $0.isUserInteractionEnabled = false
  }
  
  private let subjectContainerView = UIView().then {
    $0.layer.cornerRadius = 15
    $0.alpha = 0.1
  }
  
  init(type: VisitType) {
    super.init(frame: .zero)
    
    self.setup()
    self.bindConstraints()
    self.bind(type: type)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind(type: VisitType) {
    switch type {
    case .exists:
      self.visitImage.image = R.image.img_visit_success()
      self.subjectLabel.text = "구매 성공"
      self.subjectLabel.textColor = UIColor(r: 0, g: 198, b: 103)
      self.subjectContainerView.backgroundColor = UIColor(r: 0, g: 198, b: 103)
      
    case .notExists:
      self.visitImage.image = R.image.img_visit_fail()
      self.subjectLabel.text = "가게가 없어요"
      self.subjectLabel.textColor = R.color.red()
      self.subjectContainerView.backgroundColor = R.color.red()
    }
  }
  
  private func setup() {
    self.backgroundColor = .white
    self.layer.cornerRadius = 21
    
    self.stackView.addArrangedSubview(self.visitImage)
    self.stackView.addArrangedSubview(self.subjectContainerView)
    self.addSubViews([
      self.stackView,
      self.subjectLabel
    ])
  }
  
  private func bindConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.center.equalToSuperview()
    }
    
    self.visitImage.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.width.height.equalTo(88)
    }
    
    self.subjectContainerView.snp.makeConstraints { make in
      make.height.equalTo(30)
      make.left.equalTo(self.subjectLabel).offset(-8)
      make.right.equalTo(self.subjectLabel).offset(8)
    }
    
    self.subjectLabel.snp.makeConstraints({ make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.subjectContainerView).offset(6)
    })
  }
}
