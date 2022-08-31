import UIKit

import Base

final class HomeStoreCell: BaseCollectionViewCell {
    static let registerId = "\(HomeStoreCell.self)"
    static let itemSize: CGSize = CGSize(width: 280, height: 120)
    
    override var isSelected: Bool {
        didSet {
            self.setSelected(isSelected: self.isSelected)
        }
    }
    
    private var storeType: StoreType = .streetFood
  
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 4, height: 4)
        $0.layer.shadowOpacity = 0.08
    }
  
    private let categoryImage = UIImageView()
  
    private let titleLabel = UILabel().then {
        $0.textColor = R.color.gray100()
        $0.font = .extraBold(size: 16)
    }
  
    private let bedgeImage = UIImageView().then {
        $0.image = R.image.img_bedge()
        $0.isHidden = true
    }
  
    private let categoriesLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray40()
    }
  
    private let distanceImage = UIImageView().then {
        $0.image = R.image.ic_near_filled_pink()
    }
  
    private let distanceLabel = UILabel().then {
        $0.textColor = R.color.gray40()
        $0.font = .medium(size: 12)
    }
  
    private let starImage = UIImageView().then {
        $0.image = R.image.ic_star()
    }
  
    private let rankLabel = UILabel().then {
        $0.textColor = R.color.gray40()
        $0.font = .medium(size: 12)
    }
    
    private let isClosedTagView = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.layer.cornerRadius = 8
        $0.backgroundColor = R.color.gray60()
        $0.text = R.string.localization.home_foodtruck_closed()
        $0.font = .regular(size: 12)
        $0.isHidden = true
        $0.layer.masksToBounds = true
        $0.textColor = .white
    }
  
    let visitButton = UIButton().then {
        $0.backgroundColor = R.color.red()
        $0.layer.cornerRadius = 13
        $0.setTitle(R.string.localization.home_visit(), for: .normal)
        $0.titleEdgeInsets = .init(top: 0, left: 2, bottom: 0, right: 0)
        $0.titleLabel?.font = .bold(size: 12)
        $0.setImage(R.image.ic_dest(), for: .normal)
    }
  
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.isSelected = false
        self.bedgeImage.isHidden = true
        self.categoryImage.alpha = 1
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.containerView,
            self.categoryImage,
            self.titleLabel,
            self.bedgeImage,
            self.categoriesLabel,
            self.distanceImage,
            self.distanceLabel,
            self.starImage,
            self.rankLabel,
            self.visitButton,
            self.isClosedTagView
        ])
    }
  
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.categoryImage.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.containerView).offset(16)
            make.width.height.equalTo(40)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.containerView).offset(20)
            make.left.equalTo(self.categoryImage.snp.right).offset(8)
            make.right.equalTo(self.containerView).offset(-16)
        }
        
        self.bedgeImage.snp.makeConstraints { make in
            make.top.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-14)
            make.width.height.equalTo(24)
        }
        
        self.categoriesLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
        }
    
        self.distanceImage.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel)
            make.bottom.equalTo(self.containerView).offset(-19)
            make.width.height.equalTo(16)
        }
    
        self.distanceLabel.snp.makeConstraints { make in
            make.left.equalTo(self.distanceImage.snp.right).offset(4)
            make.centerY.equalTo(self.distanceImage)
        }
    
        self.starImage.snp.makeConstraints { make in
            make.centerY.equalTo(self.distanceImage)
            make.left.equalTo(self.distanceLabel.snp.right).offset(12)
            make.width.height.equalTo(16)
        }
    
        self.rankLabel.snp.makeConstraints { make in
            make.left.equalTo(self.starImage.snp.right).offset(4)
            make.centerY.equalTo(self.distanceLabel)
        }
        
        self.visitButton.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-14)
            make.bottom.equalTo(self.containerView).offset(-14)
            make.height.equalTo(26)
            make.width.equalTo(72)
        }
        
        self.isClosedTagView.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-16)
            make.bottom.equalTo(self.containerView).offset(-16)
        }
    }
    
    func bind(store: StoreProtocol) {
        if let store = store as? Store {
            self.storeType = .streetFood
            self.categoryImage.image = UIImage(named: "img_60_\(store.categories[0].lowcase)")
            self.setDistance(distance: store.distance)
            self.titleLabel.text = store.storeName
            self.setRating(rating: store.rating)
            self.setCategories(categories: store.categories)
            self.bedgeImage.isHidden = !store.visitHistory.isCertified
            self.visitButton.isHidden = false
            self.starImage.image = R.image.ic_star()
            self.distanceImage.image = R.image.ic_near_filled_pink()
            self.isClosedTagView.isHidden = true
        } else if let bossStore = store as? BossStore {
            self.storeType = .foodTruck
            if let category = bossStore.categories.first as? FoodTruckCategory {
                self.categoryImage.setImage(urlString: category.imageUrl)
            }
            self.setDistance(distance: bossStore.distance)
            self.titleLabel.text = bossStore.name
            self.starImage.image = R.image.ic_review_green()
            self.rankLabel.text = "\(bossStore.feedbackCount)개"
            self.setCategories(categories: bossStore.categories)
            self.distanceImage.image = R.image.ic_near_filled_green()
            self.bedgeImage.isHidden = true
            self.visitButton.isHidden = true
            self.isClosedTagView.isHidden = bossStore.status == .open
            self.categoryImage.alpha = bossStore.status == .open ? 1 : 0.4
        }
    }
  
    private func setSelected(isSelected: Bool) {
        if isSelected {
            if self.storeType == .foodTruck {
                self.starImage.image = R.image.ic_review_white()
            } else {
                self.starImage.image = R.image.ic_star_white()
            }
            self.distanceImage.image = R.image.ic_near_white()
            self.containerView.backgroundColor = .black
            self.titleLabel.textColor = .white
            self.categoriesLabel.textColor = self.storeType.themeColor
            self.distanceLabel.textColor = .white
            self.rankLabel.textColor = .white
        } else {
            if self.storeType == .foodTruck {
                self.starImage.image = R.image.ic_review_green()
                self.distanceImage.image = R.image.ic_near_filled_green()
            } else {
                self.starImage.image = R.image.ic_star()
                self.distanceImage.image = R.image.ic_near_filled_pink()
            }
            self.containerView.backgroundColor = .white
            self.titleLabel.textColor = .black
            self.categoriesLabel.textColor = R.color.gray60()
            self.distanceLabel.textColor = R.color.gray90()
            self.distanceImage.image = R.image.ic_near_filled_pink()
            self.rankLabel.textColor = R.color.gray90()
        }
  }
  
    private func setDistance(distance: Int) {
        if distance >= 1000 {
            distanceLabel.text = "1km+"
        } else {
            distanceLabel.text = "\(distance)m"
        }
    }
    
    private func setRating(rating: Double) {
        self.starImage.isHidden = false
        self.rankLabel.isHidden = false
        if floor(rating) == rating {
            self.rankLabel.text = "\(Int(rating))점"
        } else {
            self.rankLabel.text = String(format: "%.1f점", rating)
        }
    }
    
    private func setCategories(categories: [StreetFoodStoreCategory]) {
        var categoryString = ""
        for category in categories {
            categoryString.append("#\(category.name) ")
        }
        self.categoriesLabel.text = categoryString
    }
    
    private func setCategories(categories: [Categorizable]) {
        var categoryString = ""
        for category in categories {
            categoryString.append("#\(category.name) ")
        }
        self.categoriesLabel.text = categoryString
    }
}
