//
//  CountButton.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/28.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

final class CountButton: UIButton {
    
    static let size = CGSize(
        width: (UIScreen.main.bounds.width - 72 - 40)/3,
        height: (UIScreen.main.bounds.width - 72 - 40)/3
    )
    
    enum CountType {
        case store
        case review
        case title
    }
    
    private let countLabel = UILabel().then {
        $0.font = .extraBold(size: 24)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    init(type: CountType) {
        super.init(frame: .zero)
        
        self.setup(type: type)
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(count: Int) {
        self.countLabel.text = "\(count)"
    }
    
    private func setup(type: CountType) {
        self.backgroundColor = R.color.gray90()
        
        switch type {
        case .store:
            self.nameLabel.text = R.string.localization.my_page_registered_store()
            
        case .review:
            self.nameLabel.text = R.string.localization.my_page_registered_review()
            
        case .title:
            self.nameLabel.text = R.string.localization.my_page_medals()
        }
        
        self.layer.cornerRadius = 20
        self.addSubViews([
            self.countLabel,
            self.nameLabel
        ])
    }
    
    private func bindConstraints() {
        self.countLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(22)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.countLabel)
            make.right.equalTo(self.countLabel)
            make.top.equalTo(self.countLabel.snp.bottom).offset(14)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}
