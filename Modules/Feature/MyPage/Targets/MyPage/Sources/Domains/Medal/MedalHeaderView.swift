import UIKit

import Then
import SnapKit

import Model
import DesignSystem
import Common

final class MedalHeaderView: BaseCollectionViewReusableView {
    static let size = CGSize(width: UIScreen.main.bounds.width, height: 28 + 8 + 54)
    
    private let dividorView = UIView().then {
        $0.backgroundColor = Colors.gray80.color
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = .white
        $0.text = "내 칭호"
    }
    
    let infoButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_info"), for: .normal)
    }
    
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
