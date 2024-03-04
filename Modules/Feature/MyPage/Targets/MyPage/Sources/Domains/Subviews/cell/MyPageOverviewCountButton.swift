import UIKit

import Common
import DesignSystem

final class MyPageOverviewCountButton: UIButton {
    
    static let size = CGSize(
        width: ((UIScreen.main.bounds.width - 24) / 3),
        height: 68
    )
    
    enum CountType {
        case store
        case review
        case title
    }
    
    private let countLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray80.color
        $0.textAlignment = .center
    }
    
    private let nameLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray30.color
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
        self.countLabel.textColor = count == 0 ? Colors.gray80.color : Colors.gray0.color
    }
    
    private func setup(type: CountType) {
        self.backgroundColor = .clear
        
        switch type {
        case .store:
            self.nameLabel.text = "제보한 가게"
            
        case .review:
            self.nameLabel.text = "리뷰와 평가"
            
        case .title:
            self.nameLabel.text = "획득한 칭호"
        }
        
        self.addSubViews([
            self.countLabel,
            self.nameLabel
        ])
    }
    
    private func bindConstraints() {
        self.countLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.countLabel)
            make.right.equalTo(self.countLabel)
            make.top.equalTo(self.countLabel.snp.bottom).offset(2)
        }
    }
}
