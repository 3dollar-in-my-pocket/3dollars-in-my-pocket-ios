import UIKit

import Base

final class HomeAdvertisementCell: BaseCollectionViewCell {
    static let registerId = "\(HomeAdvertisementCell.self)"
    
    override var isSelected: Bool {
        didSet {
            self.setSelected(isSelected: self.isSelected)
        }
    }
  
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 4, height: 4)
        $0.layer.shadowOpacity = 0.08
    }
    
    private let advertisementLabel = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 10,
        rightInset: 10
    ).then {
        $0.backgroundColor = UIColor(r: 255, g: 92, b: 67, a: 0.2)
        $0.layer.cornerRadius = 11
        $0.textColor = R.color.red()
        $0.text = "shared_advertisement".localized
        $0.font = .medium(size: 12)
        $0.layer.masksToBounds = true
    }
  
    private let titleLabel = UILabel().then {
        $0.textColor = R.color.gray100()
        $0.font = .extraBold(size: 16)
    }
  
    private let descriptionLabel = UILabel().then {
        $0.font = .light(size: 14)
        $0.textColor = R.color.pink()
        $0.numberOfLines = 2
    }
    
    private let imageView = UIImageView()
  
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.isSelected = false
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.containerView,
            self.advertisementLabel,
            self.titleLabel,
            self.descriptionLabel,
            self.imageView
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.advertisementLabel.snp.makeConstraints { make in
            make.top.equalTo(self.containerView).offset(11)
            make.left.equalTo(self.containerView).offset(13)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.advertisementLabel)
            make.top.equalTo(self.advertisementLabel.snp.bottom).offset(10)
            make.right.equalTo(self.imageView.snp.left).offset(-8)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.advertisementLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(6)
            make.right.equalTo(self.imageView.snp.left).offset(-8)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.top.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
            make.width.equalTo(88)
        }
    }
    
    func bind(advertisement: Advertisement) {
        self.titleLabel.text = advertisement.title
        self.descriptionLabel.text = advertisement.subTitle
        self.descriptionLabel.setLineHeight(lineHeight: 16.1)
        self.imageView.setImage(urlString: advertisement.imageUrl)
    }
    
    private func setSelected(isSelected: Bool) {
        if isSelected {
            self.containerView.backgroundColor = .black
            self.titleLabel.textColor = .white
            self.descriptionLabel.textColor = .white
            
        } else {
            self.containerView.backgroundColor = .white
            self.titleLabel.textColor = .black
            self.descriptionLabel.textColor = R.color.pink()
        }
    }
}
