import UIKit

import Then
import SnapKit

import Model
import DesignSystem
import Common

final class MedalInfoTableViewCell: BaseTableViewCell {
    static let registerId = "\(MedalInfoTableViewCell.self)"
    
    private let medalImage = UIImageView()
    
    private let medalNameLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 16)
        $0.textColor = Colors.mainPink.color
    }
    
    private let acquisitionLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 14)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 14)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.addSubViews([
            self.medalImage,
            self.medalNameLabel,
            self.acquisitionLabel,
            self.descriptionLabel
        ])
    }
    
    override func bindConstraints() {
        self.medalImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(90)
        }
        
        self.medalNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.medalImage.snp.bottom).offset(8)
        }
        
        self.acquisitionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.medalNameLabel.snp.bottom).offset(12)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.acquisitionLabel)
            make.right.equalTo(self.acquisitionLabel)
            make.top.equalTo(self.acquisitionLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-32)
        }
    }
    
    func bind(medal: Medal) {
        self.medalImage.setImage(urlString: medal.iconUrl)
        self.medalNameLabel.text = medal.name
        self.acquisitionLabel.text = medal.acquisition.description
        self.descriptionLabel.text = medal.introduction
    }
}
