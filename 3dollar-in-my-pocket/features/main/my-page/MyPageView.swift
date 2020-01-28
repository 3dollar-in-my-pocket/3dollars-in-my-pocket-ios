import UIKit

class MyPageView: BaseView {
    
    let nicknameBg = UIView().then {
        $0.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 22
    }
    
    let nicknameLabel = UILabel().then {
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.textAlignment = .left
        $0.textColor = UIColor.init(r: 243, g: 162, b: 169)
    }
    
    let modifyBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_pencil"), for: .normal)
    }
    
    let bgCloud = UIImageView().then {
        $0.image = UIImage.init(named: "bg_cloud_my_page")
    }
    
    let registerLabel = UILabel().then {
        $0.text = "등록한 음식점"
        $0.textColor = .white
        $0.font = UIFont.init(name: "SpoqaHanSans-Light", size: 24)
    }
    
    let registerCountLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 24)
    }
    
    let registerTotalBtn = UIButton().then {
        $0.setTitle("전체보기", for: .normal)
        $0.setTitleColor(UIColor.init(r: 238, g: 98, b: 76), for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 14)
    }
    
    let registerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        $0.collectionViewLayout = layout
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 20, right: 196)
    }
    
    let registerEmptyImg = UIImageView().then {
        $0.image = UIImage.init(named: "img_my_page_empty")
        $0.isHidden = true
    }
    
    let reviewLabel = UILabel().then {
        $0.text = "내가 쓴 리뷰"
        $0.textColor = .white
        $0.font = UIFont.init(name: "SpoqaHanSans-Light", size: 24)
    }
    
    let reviewCountLabel = UILabel().then {
        $0.text = "10개"
        $0.textColor = .white
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 24)
    }
    
    let reviewTotalBtn = UIButton().then {
        $0.setTitle("전체보기", for: .normal)
        $0.setTitleColor(UIColor.init(r: 238, g: 98, b: 76), for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 14)
    }
    
    let reviewTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
    }
    
    let reviewEmptyImg = UIImageView().then {
        $0.image = UIImage.init(named: "img_my_page_empty")
        $0.isHidden = true
    }
    
    
    override func setup() {
        backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
        addSubViews(bgCloud, nicknameBg, nicknameLabel, modifyBtn, registerLabel,
                    registerCountLabel, registerTotalBtn, registerCollectionView, registerEmptyImg,
                    reviewLabel, reviewCountLabel, reviewTotalBtn, reviewTableView, reviewEmptyImg)
    }
    
    override func bindConstraints() {
        nicknameBg.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(40)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(44)
        }
        
        modifyBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(nicknameBg.snp.centerY)
            make.right.equalTo(nicknameBg.snp.right).offset(-16)
            make.width.height.equalTo(24)
        }
        
        nicknameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nicknameBg.snp.left).offset(16)
            make.top.equalTo(nicknameBg.snp.top).offset(11)
            make.bottom.equalTo(nicknameBg.snp.bottom).offset(-11)
            make.right.equalTo(modifyBtn.snp.right).offset(-16)
        }
        
        bgCloud.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(nicknameBg.snp.bottom).offset(19)
            make.height.equalTo(135 * RadioUtils.height)
        }
        
        registerLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.bottom.equalTo(bgCloud.snp.bottom)
        }
        
        registerCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(registerLabel.snp.right).offset(5)
            make.centerY.equalTo(registerLabel)
        }
        
        registerTotalBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(registerLabel.snp.centerY)
            make.right.equalToSuperview().offset(-24)
        }
        
        registerCollectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(registerLabel.snp.bottom).offset(16)
            make.height.equalTo(200)
        }
        
        registerEmptyImg.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(registerLabel.snp.bottom).offset(20)
            make.width.height.equalTo(112 * UIScreen.main.bounds.width / 375)
        }
        
        reviewLabel.snp.makeConstraints { (make) in
            make.left.equalTo(registerLabel.snp.left)
            make.top.equalTo(registerCollectionView.snp.bottom).offset(10)
        }
        
        reviewCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(reviewLabel.snp.right).offset(5)
            make.centerY.equalTo(reviewLabel.snp.centerY)
        }
        
        reviewTotalBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(reviewLabel.snp.centerY)
        }
        
        reviewTableView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(130)
            make.top.equalTo(reviewLabel.snp.bottom).offset(19)
        }
        
        reviewEmptyImg.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(reviewLabel.snp.bottom).offset(25)
            make.width.height.equalTo(112 * UIScreen.main.bounds.width / 375)
        }
    }
}
