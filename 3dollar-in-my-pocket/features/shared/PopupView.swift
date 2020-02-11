import UIKit

class PopupView: BaseView {
    
    let bannerBtn = UIButton().then {
        $0.backgroundColor = .gray
    }
    
    let cancelBtn = UIButton().then {
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    let disableTodayBtn1 = UIButton().then {
        $0.setBackgroundColor(.white, for: .normal)
        $0.setBackgroundColor(.black, for: .selected)
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    let disableTodayBtn2 = UIButton().then {
        $0.setTitle("오늘 하루 보지 않기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    
    override func setup() {
        backgroundColor = UIColor.init(r: 255, g: 255, b: 255, a:0.8)
        addSubViews(bannerBtn, cancelBtn, disableTodayBtn1, disableTodayBtn2)
    }
    
    override func bindConstraints() {
        bannerBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(300)
        }
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(bannerBtn)
            make.top.equalTo(bannerBtn.snp.bottom)
            make.height.equalTo(50)
        }
        
        disableTodayBtn1.snp.makeConstraints { (make) in
            make.left.equalTo(cancelBtn).offset(20)
            make.top.equalTo(cancelBtn.snp.bottom).offset(5)
            make.width.height.equalTo(20)
        }
        
        disableTodayBtn2.snp.makeConstraints { (make) in
            make.left.equalTo(disableTodayBtn1.snp.right).offset(10)
            make.centerY.equalTo(disableTodayBtn1)
        }
    }
    
    func bind(event: Event) {
        bannerBtn.kf.setImage(with: URL.init(string: event.imageUrl), for: .normal)
    }
}
