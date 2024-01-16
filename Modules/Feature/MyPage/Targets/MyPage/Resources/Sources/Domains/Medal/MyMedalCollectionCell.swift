import UIKit

import Then
import SnapKit

import Model
import DesignSystem
import Common

final class MyMedalCollectionCell: BaseCollectionViewCell {
    static let size = CGSize(
        width: UIScreen.main.bounds.width,
        height: 148
    )
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 12)
        $0.textColor = .white
    }
    
    private let containerView = UIView().then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.mainPink.color.cgColor
        $0.backgroundColor = Colors.gray95.color
        $0.layer.cornerRadius = 8
    }
    
    private let medalImage = UIImageView()
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.titleLabel,
            self.containerView,
            self.medalImage
        ])
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(24)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.right.equalTo(self.medalImage).offset(32)
            make.bottom.equalTo(self.medalImage).offset(15)
            make.bottom.equalToSuperview()
        }
        
        self.medalImage.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(32)
            make.top.equalTo(self.containerView).offset(15)
            make.width.height.equalTo(90)
        }
    }
    
    func bind(medal: Medal) {
        self.setTitle(medalName: medal.name)
        self.medalImage.setImage(urlString: medal.iconUrl)
    }
    
    private func setTitle(medalName: String) {
        let string = "현재 " + medalName + " 장착중"
        let attributedString = NSMutableAttributedString(string: string)
        let range = (string as NSString).range(of: medalName)
        
        attributedString.addAttribute(
            .foregroundColor,
            value: Colors.mainPink.color as Any,
            range: range
        )
        
        self.titleLabel.attributedText = attributedString
    }
}
