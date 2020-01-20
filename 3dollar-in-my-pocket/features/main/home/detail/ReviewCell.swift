import UIKit

class ReviewCell: BaseTableViewCell {
    
    static let registerId = "\(ReviewCell.self)"
    
    let nameLabel = UILabel().then {
        $0.text = "익명"
        $0.textColor = .black
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
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
        $0.spacing = 2
    }
    
    let replyLabel = UILabel().then {
        $0.text = "음 냠냠굿~"
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    
    override func setup() {
        stackView.addArrangedSubview(star1)
        stackView.addArrangedSubview(star2)
        stackView.addArrangedSubview(star3)
        stackView.addArrangedSubview(star4)
        stackView.addArrangedSubview(star5)
        addSubViews(nameLabel, stackView, replyLabel)
        selectionStyle = .none
        backgroundColor = .white
    }
    
    override func bindConstraints() {
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(8)
        }
        
        star1.snp.makeConstraints { (make) in
            make.width.height.equalTo(18)
        }
        
        star2.snp.makeConstraints { (make) in
            make.width.height.equalTo(18)
        }
        
        star3.snp.makeConstraints { (make) in
            make.width.height.equalTo(18)
        }
        
        star4.snp.makeConstraints { (make) in
            make.width.height.equalTo(18)
        }
        star5.snp.makeConstraints { (make) in
            make.width.height.equalTo(18)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(nameLabel.snp.centerY)
        }
        
        replyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(stackView.snp.right)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
        }
    }
    
    func bind(review: Review) {
        setRank(rank: review.rating)
        nameLabel.text = review.user?.nickname
        replyLabel.text = review.contents
    }
    
    func setRank(rank: Int) {
        if rank != 0 {
            for index in 0...stackView.arrangedSubviews.count - 1 {
                if let star = stackView.arrangedSubviews[index] as? UIButton {
                    star.isSelected = index < rank
                }
            }
        }
    }
}
