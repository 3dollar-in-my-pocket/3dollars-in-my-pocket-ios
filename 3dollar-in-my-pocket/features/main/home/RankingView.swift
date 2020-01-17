import UIKit

class RankingView: BaseView {
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
    
    let rankingLabel = UILabel().then {
        $0.text = "3.8점"
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
        $0.textColor = UIColor.init(r: 200, g: 200, b: 200)
    }
    
    override func setup() {
        backgroundColor = .clear
        stackView.addArrangedSubview(star1)
        stackView.addArrangedSubview(star2)
        stackView.addArrangedSubview(star3)
        stackView.addArrangedSubview(star4)
        stackView.addArrangedSubview(star5)
        addSubViews(stackView, rankingLabel)
    }
    
    override func bindConstraints() {
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
            make.left.centerY.equalToSuperview()
        }
        
        rankingLabel.snp.makeConstraints { (make) in
            make.left.equalTo(stackView.snp.right).offset(8)
            make.centerY.equalTo(stackView.snp.centerY)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.sizeToFit()
    }
    
    func setRank(rank: Float) {
        for index in 0...Int(rank.rounded()) {
            if let star = stackView.arrangedSubviews[index] as? UIButton {
                star.isSelected = true
            }
        }
        rankingLabel.text = "\(rank)"
    }
    
    func setSelected(isSelected: Bool) {
        if isSelected {
            rankingLabel.textColor = .white
        } else {
            rankingLabel.textColor = UIColor.init(r: 200, g: 200, b: 200)
        }
    }
}
