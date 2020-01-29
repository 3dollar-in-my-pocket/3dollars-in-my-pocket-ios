import UIKit

class MyPageReviewCell: BaseTableViewCell {
    
    static let registerId = "\(MyPageReviewCell.self)"
    
    let categoryImage = UIImageView().then {
        $0.image = UIImage.init(named: "img_card_bungeoppang_on")
        $0.contentMode = .scaleAspectFit
    }
    
    let reviewLabel = UILabel().then {
        $0.text = "음~냠냠긋~"
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 14)
        $0.textColor = .white
    }
    
    let star1 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    let star2 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    let star3 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    let star4 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    let star5 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.backgroundColor = .clear
        $0.spacing = 4
    }
    
    
    override func setup() {
        selectionStyle = .none
        stackView.addArrangedSubview(star1)
        stackView.addArrangedSubview(star2)
        stackView.addArrangedSubview(star3)
        stackView.addArrangedSubview(star4)
        stackView.addArrangedSubview(star5)
        addSubViews(categoryImage, reviewLabel, stackView)
    }
    
    override func bindConstraints() {
        categoryImage.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(24)
        }
        
        star1.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
        }
        
        star2.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
        }
        
        star3.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
        }
        
        star4.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
        }
        
        star5.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(categoryImage.snp.centerY)
            make.right.equalToSuperview().offset(-18)
        }
        
        reviewLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(categoryImage.snp.centerY)
            make.left.equalTo(categoryImage.snp.right).offset(23)
            make.right.equalTo(stackView.snp.left)
        }
    }
    
    func setTopRadius() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setBottomRadius() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func setOddBg() {
        backgroundColor = UIColor.init(r: 46, g: 46, b: 46)
    }
    
    func setEvenBg() {
        backgroundColor = UIColor.init(r: 74, g: 74, b: 74)
    }
    
    func bind(review: Review) {
        switch review.category {
        case .BUNGEOPPANG:
            categoryImage.image = UIImage.init(named: "img_review_bungeoppang")
        case .GYERANPPANG:
            categoryImage.image = UIImage.init(named: "img_review_gyeranppang")
        case .HOTTEOK:
            categoryImage.image = UIImage.init(named: "img_review_hotteok")
        case .TAKOYAKI:
            categoryImage.image = UIImage.init(named: "img_review_takoyaki")
        default:
            break
        }
        
        reviewLabel.text = review.contents
        setRank(rank: review.rating)
    }
    
    func setRank(rank: Int) {
        for index in 0...stackView.arrangedSubviews.count - 1 {
            if let star = stackView.arrangedSubviews[index] as? UIButton {
                star.isSelected = index < rank
            }
        }
    }
}
