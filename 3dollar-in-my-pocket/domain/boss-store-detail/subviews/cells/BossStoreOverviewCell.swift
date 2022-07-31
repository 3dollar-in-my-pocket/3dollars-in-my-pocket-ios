import UIKit

import Base
import NMapsMap
import Kingfisher

final class BossStoreOverviewCell: BaseCollectionViewCell {
    static let registerId = "\(BossStoreOverviewCell.self)"
    static let height: CGFloat = 436
    
    private let photoView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = R.color.gray5()
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 8, height: 8)
        $0.layer.shadowOpacity = 0.04
    }
    
    private let mapView = NMFMapView().then {
        $0.zoomLevel = 15
        $0.layer.cornerRadius = 10
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .bold(size: 24)
        $0.textColor = R.color.gray100()
        $0.textAlignment = .center
    }
    
    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.distribution = .equalSpacing
        $0.alignment = .fill
    }
    
    let shareButton = UIButton().then {
        $0.setImage(R.image.ic_share(), for: .normal)
        $0.setTitle(R.string.localization.boss_store_share(), for: .normal)
        $0.setTitleColor(R.color.black(), for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.categoryStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    override func setup() {
        self.addSubViews([
            self.mapView,
            self.photoView,
            self.containerView,
            self.nameLabel,
            self.categoryStackView,
            self.shareButton
        ])
    }
    
    override func bindConstraints() {
        self.photoView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(240)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.photoView.snp.bottom).offset(-40)
            make.bottom.equalToSuperview().offset(-7)
        }
        
        self.mapView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.containerView).offset(16)
            make.height.equalTo(108)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.containerView).offset(20)
        }
        
        self.categoryStackView.snp.makeConstraints { make in
            make.centerX.equalTo(self.containerView)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(8)
        }
        
        self.shareButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.top.equalTo(self.categoryStackView.snp.bottom).offset(16)
            make.height.equalTo(56)
        }
    }
    
    func bind(store: BossStore) {
        self.nameLabel.text = store.name
        
        if let imageURL = store.imageURL {
            self.photoView.setImage(urlString: imageURL)
        }
        
        for category in store.categories {
            let categoryLagel = PaddingLabel(
                topInset: 4,
                bottomInset: 4,
                leftInset: 8,
                rightInset: 8
            ).then {
                $0.backgroundColor = UIColor(r: 0, g: 198, b: 103, a: 0.1)
                $0.textColor = .green
                $0.layer.cornerRadius = 8
                $0.text = category.name
                $0.layer.masksToBounds = true
                $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            }
            
            self.categoryStackView.addArrangedSubview(categoryLagel)
        }
    }
}
