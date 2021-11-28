//
//  MyVisitHistoryCell.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/28.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

final class MyVisitHistoryCell: BaseCollectionViewCell {
    
    static let registerId = "\(MyVisitHistoryCell.self)"
    static let size = CGSize(width: 162, height: 112)
    
    private let visitDateLabel = VisitDateView()
    
    private let storeContainerView = UIView().then {
        $0.backgroundColor = R.color.gray95()
        $0.layer.cornerRadius = 15
    }
    
    private let categoryImage = UIImageView().then {
        $0.image = R.image.img_32_bungeoppang_on()
    }
    
    private let storeNameLabel = UILabel().then {
        $0.font = .medium(size: 16)
        $0.textColor = .white
        $0.text = "강남역 0번 출구"
    }
    
    private let categoryLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray30()
        $0.text = "#붕어빵 #땅콩과자 #호떡"
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.storeContainerView,
            self.categoryImage,
            self.categoryLabel
        ])
    }
    
    override func bindConstraints() {
        self.visitDateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.storeContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(self.visitDateLabel.snp.bottom).offset(8)
            make.width.equalTo(Self.size.width)
        }
        
        self.categoryImage.snp.makeConstraints { make in
            make.left.equalTo(self.storeContainerView).offset(16)
            make.centerY.equalTo(self.storeContainerView)
        }
        
        self.storeNameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.categoryImage.snp.right).offset(8)
            make.top.equalTo(self.storeContainerView).offset(20)
            make.right.equalTo(self.storeContainerView).offset(-16)
        }
        
        self.categoryLabel.snp.makeConstraints { make in
            make.left.equalTo(self.storeNameLabel)
            make.top.equalTo(self.storeNameLabel.snp.bottom).offset(8)
            make.right.equalTo(self.storeNameLabel)
        }
    }
}
