import UIKit

class CategoryButton: BaseView {
    
    let icon = UIImageView().then {
        $0.image = UIImage.init(named: "img_category_fish")
        $0.contentMode = .scaleAspectFit
    }
    
    let title = UILabel().then {
        $0.text = "붕어빵"
        $0.textColor = UIColor.init(r: 79, g: 79, b: 79)
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 14)
    }
    
    override func setup() {
        backgroundColor = .clear
        addSubViews(icon, title)
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
}
