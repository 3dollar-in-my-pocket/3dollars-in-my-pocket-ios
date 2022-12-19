//
//  TitleLabel.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/28.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

final class TitleLabel: BaseView {
    enum TitleType {
        case small
        case big
    }
    
    private let type: TitleType
    
    private let outlineView = UIView().then {
        $0.layer.cornerRadius = 15
        $0.layer.borderColor = Color.pink?.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = Color.pink
    }
    
    init(type: TitleType) {
        self.type = type
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        switch self.type {
        case .small:
            self.titleLabel.font = .regular(size: 12)
            self.outlineView.layer.cornerRadius = 11
            
        case .big:
            self.titleLabel.font = .medium(size: 14)
            self.outlineView.layer.cornerRadius = 15
        }
    }
    
    override func bindConstraints() {
        switch self.type {
        case .small:
            self.outlineView.snp.makeConstraints { make in
                make.left.equalTo(self.titleLabel).offset(-6)
                make.right.equalTo(self.titleLabel).offset(6)
                make.top.equalTo(self.titleLabel).offset(-4)
                make.bottom.equalTo(self.titleLabel).offset(4)
            }
        case .big:
            self.outlineView.snp.makeConstraints { make in
                make.left.equalTo(self.titleLabel).offset(-10)
                make.right.equalTo(self.titleLabel).offset(10)
                make.top.equalTo(self.titleLabel).offset(-6)
                make.bottom.equalTo(self.titleLabel).offset(6)
            }
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.outlineView)
        }
    }
}
