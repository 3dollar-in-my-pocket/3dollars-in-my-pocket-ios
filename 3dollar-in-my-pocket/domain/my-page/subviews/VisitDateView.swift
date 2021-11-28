//
//  VisitDateView.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/28.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

final class VisitDateView: BaseView {
    
    private let visitDateContainerView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.alpha = 0.1
    }
    
    private let visitImage = UIImageView().then {
        $0.image = R.image.img_exist()
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .medium(size: 12)
        $0.text = "10월 1일 19:23:00"
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.visitDateContainerView,
            self.visitImage,
            self.dateLabel
        ])
    }
    
    override func bindConstraints() {
        self.visitImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.top.equalToSuperview().offset(6)
            make.width.height.equalTo(12)
        }
        
        self.dateLabel.snp.makeConstraints { make in
            make.left.equalTo(self.visitImage.snp.right).offset(6)
            make.centerY.equalTo(self.visitImage)
        }
        
        self.visitDateContainerView.snp.makeConstraints { make in
            make.left.equalTo(self.visitImage).offset(-6).priority(.high)
            make.top.equalTo(self.visitImage).offset(-6).priority(.high)
            make.bottom.equalTo(self.visitImage).offset(6).priority(.high)
            make.right.equalTo(self.visitImage).offset(6).priority(.high)
        }
    }
}
