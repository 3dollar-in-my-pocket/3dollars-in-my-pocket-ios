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
  
  private let categoryImageBackground = UIView().then {
    $0.backgroundColor = UIColor(r: 196, g: 196, b: 196)
    $0.layer.cornerRadius = 40
    $0.isUserInteractionEnabled = false
  }
  
  private let categoryImage = UIImageView().then {
    $0.isUserInteractionEnabled = false
  }
  
  private let subjectLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .semiBold(size: 16)
    $0.isUserInteractionEnabled = false
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
      self.subjectLabel.text = "가게가 있어요!"
      
    case .notExists:
      self.subjectLabel.text = "가게가 없어요!"
    }
  }
  
  private func setup() {
    self.backgroundColor = R.color.gray10()
    self.layer.cornerRadius = 21
    
    self.addSubViews([
      self.categoryImageBackground,
      self.categoryImage,
      self.subjectLabel
    ])
  }
  
  private func bindConstraints() {
    self.categoryImageBackground.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(18)
      make.width.height.equalTo(80)
    }
    
    self.categoryImage.snp.makeConstraints { make in
      make.center.equalTo(self.categoryImageBackground)
    }
    
    self.subjectLabel.snp.makeConstraints({ make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.categoryImageBackground.snp.bottom).offset(22)
    })
  }
}
