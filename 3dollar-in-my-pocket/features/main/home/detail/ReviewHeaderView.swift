import UIKit

class ReviewHeaderView: BaseView {
    
    let seperator = UIView().then {
        $0.backgroundColor = UIColor.init(r: 245, g: 245, b: 245)
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.init(r: 227, g: 227, b: 227).cgColor
    }
    
    let reviewCountLabel = UILabel().then {
        $0.text = "리뷰 20개"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 20)
        $0.textColor = UIColor.init(r: 55, g: 55, b: 55)
    }
    
    
    override func setup() {
        addSubViews(seperator, reviewCountLabel)
    }
    
    override func bindConstraints() {
        seperator.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(7)
        }
        
        reviewCountLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(seperator.snp.bottom).offset(24)
        }
    }
}
