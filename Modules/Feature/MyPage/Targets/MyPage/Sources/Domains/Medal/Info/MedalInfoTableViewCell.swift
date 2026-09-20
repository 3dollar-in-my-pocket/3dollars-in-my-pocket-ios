import UIKit

import SnapKit

import Model
import DesignSystem
import Common

final class MedalInfoTableViewCell: BaseTableViewCell {
    static let registerId = "\(MedalInfoTableViewCell.self)"
    
    private let medalImage = UIImageView()
    
    private let medalNameLabel: UILabel = {
        let medalNameLabel = UILabel()
        medalNameLabel.font = Fonts.medium.font(size: 16)
        medalNameLabel.textColor = Colors.mainPink.color
        return medalNameLabel
    }()
    
    private let acquisitionLabel: UILabel = {
        let acquisitionLabel = UILabel()
        acquisitionLabel.font = Fonts.bold.font(size: 14)
        acquisitionLabel.textColor = .white
        acquisitionLabel.textAlignment = .center
        return acquisitionLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = Fonts.regular.font(size: 14)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        return descriptionLabel
    }()
    
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
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(self.medalNameLabel.snp.bottom).offset(12)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.acquisitionLabel)
            make.trailing.equalTo(self.acquisitionLabel)
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
