import UIKit

class NicknameView: BaseView {
    
    private let titleLabel = UILabel().then {
        $0.text = "닉네임"
    }
    
    private let nicknameField = UITextField().then {
        $0.placeholder = "입력해주세요."
    }
    
    let button = UIButton().then {
        $0.setTitle("입장하기", for: .normal)
        $0.backgroundColor = .black
        $0.setTitleColor(.white, for: .normal)
    }
    
    
    override func setup() {
        backgroundColor = .white
        addSubViews(titleLabel, nicknameField, button)
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        nicknameField.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
        }
        
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(nicknameField.snp.bottom)
        }
    }
}
