import UIKit

class CategoryButton: BaseView {
    
    var category: StoreCategory!
    
    let icon = UIImageView().then {
        $0.image = UIImage.init(named: "img_category_fish")
        $0.contentMode = .scaleAspectFit
    }
    
    let title = UILabel().then {
        $0.text = "붕어빵"
        $0.textColor = UIColor.init(r: 79, g: 79, b: 79)
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 14)
    }
    
    init(category: StoreCategory) {
        self.category = category
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setup() {
        backgroundColor = .clear
        addSubViews(icon, title)
        configure()
    }
    
    override func bindConstraints() {
        icon.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.width.equalTo(67)
        }
        
        title.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(icon.snp.bottom)
        }
    }
    
    func configure() {
        switch category {
        case .BUNGEOPPANG:
            icon.image = UIImage.init(named: "img_category_fish")
            title.text = "붕어빵"
        case .GYERANPPANG:
            icon.image = UIImage.init(named: "img_category_geyranppang")
            title.text = "계란빵"
        case .HOTTEOK:
            icon.image = UIImage.init(named: "img_category_hotteok")
            title.text = "호떡"
        case .TAKOYAKI:
            icon.image = UIImage.init(named: "img_category_takoyaki")
            title.text = "타코야끼"
        default:
            break
        }
    }
}
