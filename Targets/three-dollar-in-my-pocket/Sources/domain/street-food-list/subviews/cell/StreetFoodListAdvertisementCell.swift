import UIKit

import RxSwift
import RxCocoa

final class StreetFoodListAdvertisementCell: BaseCollectionViewCell {
    static let registerId = "\(StreetFoodListAdvertisementCell.self)"
    static let height: CGFloat = 150
    fileprivate let tapGesture = UITapGestureRecognizer()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let advertisementLabel = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 10,
        rightInset: 10
    ).then {
        $0.backgroundColor = UIColor(r: 255, g: 92, b: 67, a: 0.2)
        $0.layer.cornerRadius = 11
        $0.textColor = Color.red
        $0.text = "shared_advertisement".localized
        $0.font = .medium(size: 12)
        $0.layer.masksToBounds = true
    }
    
    private let moreLabel = UILabel().then {
        $0.text = "shared_advertisement_more".localized
        $0.textColor = Color.pink
        $0.font = .regular(size: 12)
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = Color.black
        $0.font = .extraBold(size: 16)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = Color.gray60
        $0.font = .regular(size: 12)
        $0.numberOfLines = 2
    }
    
    private let image = UIImageView().then {
        $0.backgroundColor = Color.gray5
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFit
    }
    
    override func setup() {
        self.contentView.isUserInteractionEnabled = false
        self.addGestureRecognizer(self.tapGesture)
        self.backgroundColor = .clear
        self.contentView.addSubViews([
            self.containerView,
            self.advertisementLabel,
            self.moreLabel,
            self.titleLabel,
            self.descriptionLabel,
            self.image
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(134).priority(.high)
        }
        
        self.advertisementLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.containerView).offset(16)
        }
        
        self.moreLabel.snp.makeConstraints { make in
            make.top.equalTo(self.containerView).offset(20)
            make.right.equalTo(self.containerView).offset(-16)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.advertisementLabel.snp.bottom).offset(18)
            make.right.equalTo(self.image.snp.left).offset(-12)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel)
            make.right.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
        }
        
        self.image.snp.makeConstraints { make in
            make.top.equalTo(self.advertisementLabel.snp.bottom).offset(12)
            make.right.equalTo(self.containerView).offset(-16)
            make.width.equalTo(120)
            make.height.equalTo(68)
        }
    }
    
    func bind(advertisement: Advertisement) {
        self.titleLabel.text = advertisement.title
        self.descriptionLabel.text = advertisement.subTitle
        self.image.setImage(urlString: advertisement.imageUrl)
    }
}

extension Reactive where Base: StreetFoodListAdvertisementCell {
    var tap: ControlEvent<Void> {
        return ControlEvent(events: base.tapGesture.rx.event.map { _ in () })
    }
}
