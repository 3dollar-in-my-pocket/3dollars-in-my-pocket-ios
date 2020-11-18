import UIKit

class CategoryChildView: BaseView {
    var category: StoreCategory!
    
    let descLabel1 = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 24)
    }
    
    let descLabel2 = UILabel().then {
        let text = "만나기 30초 전"
        let attributedText = NSMutableAttributedString(string: text)
        
        attributedText.addAttribute(.kern, value: -1.6, range: NSMakeRange(0, text.count-1))
        $0.textColor = .black
        $0.font = UIFont.init(name: "SpoqaHanSans-Light", size: 24)
        $0.attributedText = attributedText
    }
    
    let nearOrderBtn = UIButton().then {
        $0.setTitle("거리순", for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(UIColor.init(r: 189, g: 189, b: 189), for: .normal)
        $0.isSelected = true
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 14)
    }
    
    let reviewOrderBtn = UIButton().then {
        $0.setTitle("별점순", for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(UIColor.init(r: 189, g: 189, b: 189), for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 14)
    }
    
    let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = UIColor.init(r: 245, g: 245, b: 245)
        $0.tableFooterView = UIView()
        $0.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.showsVerticalScrollIndicator = false
    }
    
    let emptyImg = UIImageView().then {
        $0.image = UIImage.init(named: "img_my_page_empty")
        $0.isHidden = true
    }
    
    let emptyLabel = UILabel().then {
        $0.text = "1km 근처에 가게가 없어요."
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16 * RadioUtils.width)
        $0.textColor = UIColor.init(r: 200, g: 200, b: 200)
        $0.isHidden = true
    }
    
    init(category: StoreCategory) {
        self.category = category
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func setup() {
        backgroundColor = UIColor.init(r: 245, g: 245, b: 245)
        addSubViews(descLabel1, descLabel2, nearOrderBtn, reviewOrderBtn, tableView, emptyImg, emptyLabel)
    }
    
    override func bindConstraints() {
        descLabel1.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(41)
            make.left.equalToSuperview().offset(24)
        }
        
        descLabel2.snp.makeConstraints { (make) in
            make.centerY.equalTo(descLabel1.snp.centerY)
            make.left.equalTo(descLabel1.snp.right).offset(3)
        }
        
        reviewOrderBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-25)
            make.top.equalToSuperview().offset(49)
        }
        
        nearOrderBtn.snp.makeConstraints { (make) in
            make.right.equalTo(reviewOrderBtn.snp.left).offset(-13)
            make.centerY.equalTo(reviewOrderBtn.snp.centerY)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(descLabel1.snp.bottom).offset(5)
        }
        
        emptyImg.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(descLabel1.snp.bottom).offset(54)
            make.width.equalTo(112)
            make.height.equalTo(112)
        }
        
        emptyLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyImg.snp.bottom).offset(8)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch category {
        case .BUNGEOPPANG:
            descLabel1.text = "붕어빵"
            descLabel2.text = "만나기 30초 전"
        case .GYERANPPANG:
            descLabel1.text = "계란빵,"
            descLabel2.text = "내 입으로"
        case .HOTTEOK:
            descLabel1.text = "호떡아"
            descLabel2.text = "기다려"
        case .TAKOYAKI:
            descLabel1.text = "문어빵,"
            descLabel2.text = "다 내꺼야"
        default:
            descLabel1.text = "붕어빵"
            descLabel2.text = "만나기 30초 전"
        }
    }
    
    func setEmpty(isEmpty: Bool) {
        emptyImg.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
    }
}
