import UIKit

import SnapKit

import Model
import DesignSystem
import Common

final class MedalHeaderView: BaseCollectionViewReusableView {
    static let size = CGSize(width: UIScreen.main.bounds.width, height: 28 + 8 + 54)
    
    private let dividorView: UIView = {
        let dividorView = UIView()
        dividorView.backgroundColor = Colors.gray80.color
        return dividorView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.medium.font(size: 12)
        titleLabel.textColor = .white
        titleLabel.text = "내 칭호"
        return titleLabel
    }()
    
    let infoButton: UIButton = {
        let infoButton = UIButton()
        infoButton.setImage(UIImage(named: "ic_info"), for: .normal)
        return infoButton
    }()
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.dividorView,
            self.titleLabel,
            self.infoButton
        ])
    }
    
    override func bindConstraints() {
        self.dividorView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(28)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(8)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(self.dividorView.snp.bottom).offset(24)
        }
        
        self.infoButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel)
            make.left.equalTo(self.titleLabel.snp.right).offset(8)
        }
    }
    
    func bind(title: String) {
        self.titleLabel.text = title
    }
}
