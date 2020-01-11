import UIKit

class SplashView: BaseView {
    let titleLabel = UILabel().then {
        $0.text = "Splash 화면 입니다."
        $0.textColor = .black
    }
    
    override func setup() {
        backgroundColor = .white
        addSubViews(titleLabel)
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
