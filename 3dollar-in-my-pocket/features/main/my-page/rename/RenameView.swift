import UIKit

class RenameView: BaseView {
    
    let tapGestureView = UITapGestureRecognizer()
    
    let backBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_back_white"), for: .normal)
    }
    
    let titleLabel = UILabel().then {
        $0.text = "닉네임 수정"
        $0.textColor = .white
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let bgCloud = UIImageView().then {
        $0.image = UIImage.init(named: "bg_cloud")
        $0.contentMode = .scaleToFill
    }
    
    let oldNicknameLabel = UILabel().then {
        $0.textColor = UIColor.init(r: 243, g: 162, b: 169)
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 32)
    }
    
    let nicknameLabel1 = UILabel().then {
        $0.text = "를"
        $0.textColor = .white
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 32)
    }
    
    let nicknameFieldBg = UIView().then {
        $0.layer.cornerRadius = 28
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
        $0.backgroundColor = .clear
    }
    
    let nicknameField = UITextField().then {
        $0.placeholder = "닉네임 입력"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 32)
        $0.textColor = UIColor.init(r: 243, g: 162, b: 169)
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(string: "닉네임 입력",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(r: 243, g: 162, b: 169, a: 0.4)])
    }
    
    let nicknameLabel2 = UILabel().then {
        $0.text = "로"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 32)
        $0.textColor = .white
    }
    
    let startBtn1 = UIButton().then {
        $0.setTitle("수정할래요", for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 32)
        $0.setTitleColor(.white, for: .disabled)
        $0.setTitleColor(UIColor.init(r: 238, g: 98, b: 76), for: .normal)
    }
    
    let startBtn2 = UIButton().then {
        $0.setImage(UIImage.init(named: "img_start_off_disable"), for: .disabled)
        $0.setImage(UIImage.init(named: "img_start_off_normal"), for: .normal)
        $0.backgroundColor = .clear
    }
    
    override func setup() {
        backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
        addGestureRecognizer(tapGestureView)
        addSubViews(backBtn, titleLabel, bgCloud, oldNicknameLabel, nicknameLabel1, nicknameFieldBg,
                    nicknameField, nicknameLabel2, startBtn1, startBtn2)
    }
    
    override func bindConstraints() {
        
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(48)
            make.width.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backBtn.snp.centerY)
            make.centerX.equalToSuperview()
        }
        
        bgCloud.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(backBtn.snp.bottom).offset(44)
        }
        
        oldNicknameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bgCloud.snp.left).offset(24)
            make.top.equalTo(bgCloud.snp.top).offset(161)
        }
        
        nicknameLabel1.snp.makeConstraints { (make) in
            make.left.equalTo(oldNicknameLabel.snp.right).offset(5)
            make.centerY.equalTo(oldNicknameLabel.snp.centerY)
        }
        
        nicknameFieldBg.snp.makeConstraints { (make) in
            make.left.equalTo(oldNicknameLabel.snp.left)
            make.top.equalTo(oldNicknameLabel.snp.bottom).offset(16)
            make.height.equalTo(56)
            make.width.equalTo(282)
        }
        
        nicknameField.snp.makeConstraints { (make) in
            make.left.equalTo(nicknameFieldBg.snp.left).offset(20)
            make.top.equalTo(nicknameFieldBg.snp.top)
            make.bottom.equalTo(nicknameFieldBg.snp.bottom)
            make.right.equalTo(nicknameFieldBg.snp.right).offset(-20)
        }
        
        nicknameLabel2.snp.makeConstraints { (make) in
            make.centerY.equalTo(nicknameFieldBg.snp.centerY)
            make.left.equalTo(nicknameFieldBg.snp.right).offset(14)
        }
        
        startBtn1.snp.makeConstraints { (make) in
            make.left.equalTo(oldNicknameLabel.snp.left)
            make.top.equalTo(nicknameFieldBg.snp.bottom).offset(16)
            make.height.equalTo(38)
        }
        
        startBtn2.snp.makeConstraints { (make) in
            make.centerY.equalTo(startBtn1.snp.centerY)
            make.left.equalTo(startBtn1.snp.right).offset(8)
        }
    }
    
    func setBtnEnable(isEnable: Bool) {
        startBtn1.isEnabled = isEnable
        startBtn2.isEnabled = isEnable
    }
}
