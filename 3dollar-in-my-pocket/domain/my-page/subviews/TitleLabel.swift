//
//  TitleLabel.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/28.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

final class TitleLabel: UIView {
    private let outlineView = UIView().then {
        $0.layer.cornerRadius = 15
        $0.layer.borderColor = R.color.pink()?.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = R.color.pink()
        $0.font = .medium(size: 14)
    }
    
    init() {
        super.init(frame: .zero)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(title: String) {
        self.titleLabel.text = title
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.outlineView,
            self.titleLabel
        ])
    }
    
    private func bindConstraints() {
        self.outlineView.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel).offset(-10)
            make.right.equalTo(self.titleLabel).offset(10)
            make.top.equalTo(self.titleLabel).offset(-6)
            make.bottom.equalTo(self.titleLabel).offset(6)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.outlineView)
        }
    }
}
