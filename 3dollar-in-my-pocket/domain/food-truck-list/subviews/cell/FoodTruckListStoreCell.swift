import UIKit

import Base
import RxSwift
import RxCocoa

final class FoodTruckListStoreCell: BaseCollectionViewCell {
    static let registerId = "\(FoodTruckListStoreCell.self)"
    static let height: CGFloat = 90
    fileprivate let tapGesture = UITapGestureRecognizer()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let titleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = R.color.black()
        $0.font = R.font.appleSDGothicNeoEB00(size: 16)
    }
    
    private let categoriesLabel = UILabel().then {
        $0.textColor = R.color.gray60()
        $0.font = .regular(size: 12)
    }
    
    private let distanceImage = UIImageView().then {
        $0.image = R.image.ic_near_filled_green()
    }
    
    private let distanceLabel = UILabel().then {
        $0.textColor = R.color.black()
        $0.font = .medium(size: 14)
    }
    
    private let ratingImage = UIImageView().then {
        $0.image = R.image.ic_review_green()
    }
    
    private let reviewCountLabel = UILabel().then {
        $0.textColor = R.color.black()
        $0.font = .medium(size: 14)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleStackView.subviews.forEach { $0.removeFromSuperview()}
        self.containerView.isHidden = false
        self.distanceImage.isHidden = false
        self.ratingImage.isHidden = false
    }
    
    override func setup() {
        self.contentView.isUserInteractionEnabled = false
        self.addGestureRecognizer(self.tapGesture)
        self.backgroundColor = .clear
        self.addSubViews([
            self.containerView,
            self.titleStackView,
            self.categoriesLabel,
            self.reviewCountLabel,
            self.ratingImage,
            self.distanceLabel,
            self.distanceImage
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(74)
            make.bottom.equalToSuperview()
        }
        
        self.titleStackView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.containerView).offset(20)
        }
        
        self.categoriesLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView.snp.centerX)
            make.bottom.equalTo(self.containerView).offset(-14)
        }
        
        self.reviewCountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.containerView).offset(-21)
            make.centerY.equalTo(self.categoriesLabel)
        }
        
        self.ratingImage.snp.makeConstraints { make in
            make.right.equalTo(self.reviewCountLabel.snp.left).offset(-4)
            make.centerY.equalTo(self.categoriesLabel)
            make.width.height.equalTo(16)
        }
        
        self.distanceLabel.snp.makeConstraints { make in
            make.right.equalTo(self.ratingImage.snp.left).offset(-8)
            make.centerY.equalTo(self.categoriesLabel)
        }
        
        self.distanceImage.snp.makeConstraints { make in
            make.right.equalTo(self.distanceLabel.snp.left).offset(-4)
            make.centerY.equalTo(self.categoriesLabel)
            make.width.height.equalTo(16)
        }
    }
    
    func bind(store: BossStore) {
        self.titleLabel.text = store.name
        
        self.titleStackView.addArrangedSubview(self.titleLabel)
        self.reviewCountLabel.text = String.init(format: "%d개", store.feedbackCount)
        if store.distance >= 1000 {
            self.distanceLabel.text = String.init(format: "%.2fkm", Double(store.distance) / 1000)
        } else {
            self.distanceLabel.text = String.init(format: "%dm", store.distance)
        }
        self.categoriesLabel.text = store.categoriesString
    }
}

extension Reactive where Base: FoodTruckListStoreCell {
    var tap: ControlEvent<Void> {
        return ControlEvent(events: base.tapGesture.rx.event.map { _ in () })
    }
}
