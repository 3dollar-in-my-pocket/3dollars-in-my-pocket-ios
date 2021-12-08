//
//  ReviewTitleLabel.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/12/08.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

final class ReviewTitleLabel: BaseView {
    private let outlineView = UIView().then {
        $0.layer.cornerRadius = 11
        $0.layer.borderColor = UIColor(r: 235, g: 87, b: 87).cgColor
        $0.layer.borderWidth = 1
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = UIColor(r: 235, g: 87, b: 87)
        $0.font = .regular(size: 12)
        $0.text = "붕어빵챌린저"
    }
    
    func bind(title: String) {
        self.titleLabel.text = title
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.outlineView,
            self.titleLabel
        ])
    }
    
    override func bindConstraints() {
        self.outlineView.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel).offset(-6)
            make.right.equalTo(self.titleLabel).offset(6)
            make.top.equalTo(self.titleLabel).offset(-4)
            make.bottom.equalTo(self.titleLabel).offset(4)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.outlineView)
        }
    }
}
