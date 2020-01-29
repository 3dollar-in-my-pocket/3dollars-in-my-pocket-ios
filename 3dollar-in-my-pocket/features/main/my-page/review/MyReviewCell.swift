import UIKit

class MyReviewCell: BaseTableViewCell {
    
    static let registerId = "\(MyReviewCell.self)"
    
    let background = UIView().then {
        $0.backgroundColor = UIColor.init(r: 74, g: 74, b: 74)
        $0.layer.cornerRadius = 16
    }
    
    let categoryImage = UIImageView().then {
        $0.image = UIImage.init(named: "img_card_bungeoppang_on")
    }
    
    let titleLabel = UILabel().then {
        $0.text = "강남역 2번출구 앞"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.textColor = UIColor.init(r: 243, g: 162, b: 169)
    }
    
    let reviewLabel = UILabel().then {
        $0.text = "음~ 냠냠긋 음~ 냠냠긋~음~ 냠냠긋~음~ 냠냠긋~음~ 냠냠긋~음~ 냠냠긋~음~ 냠냠긋~"
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 14)
        $0.numberOfLines = 0
        $0.textColor = .white
    }
    
    let rankingView = RankingView()
    
    
    override func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        addSubViews(background, categoryImage, titleLabel, reviewLabel, rankingView)
    }
    
    override func bindConstraints() {
        categoryImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(17)
            make.left.equalTo(background.snp.left).offset(16)
            make.width.equalTo(40)
            make.height.equalTo(25)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(categoryImage.snp.centerY)
            make.left.equalTo(categoryImage.snp.right).offset(16)
        }
        
        reviewLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.right.equalTo(background.snp.right).offset(-14)
        }
        
        rankingView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(reviewLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-25)
        }
        
        background.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.top).offset(-15)
            make.bottom.equalTo(rankingView.snp.bottom).offset(20)
        }
    }
    
    func bind(review: Review) {
        switch review.category {
        case .BUNGEOPPANG:
            categoryImage.image = UIImage.init(named: "img_card_bungeoppang_on")
        case .GYERANPPANG:
            categoryImage.image = UIImage.init(named: "img_card_gyeranppang_on")
        case.HOTTEOK:
            categoryImage.image = UIImage.init(named: "img_card_hotteok_on")
        case.TAKOYAKI:
            categoryImage.image = UIImage.init(named: "img_card_takoyaki_on")
        default:
            break
        }
        titleLabel.text = review.storeName
        reviewLabel.text = review.contents
        rankingView.setRank(rank: Float(review.rating))
    }
}
