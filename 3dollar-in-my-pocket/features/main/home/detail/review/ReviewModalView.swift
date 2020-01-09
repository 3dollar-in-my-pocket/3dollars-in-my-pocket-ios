import UIKit

protocol ReviewModalViewDelegate: class {
    func onTapRegister()
}

class ReviewModalView: BaseView {
    
    weak var delegate: ReviewModalViewDelegate?
    
    let containerView = UIView().then {
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .white
    }
    
    let titleLabel = UILabel().then {
        $0.text = "이 가게를\n추천하시나요?"
        $0.font = UIFont.init(name: "SpoqaHanSans-Light", size: 28)
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    let star1 = UIButton().then {
        $0.imageView?.contentMode = .scaleAspectFill
        $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
    }
    
    let star2 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
    }
    
    let star3 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
    }
    
    let star4 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
    }
    
    let star5 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_off"), for: .normal)
    }
    
    let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.backgroundColor = .clear
        $0.spacing = 2
    }
    
    let stackContainer = UIView().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
        $0.layer.borderWidth = 1
    }
    
    let reviewField = UITextField().then {
        $0.placeholder = "솔직한 리뷰를 남겨주세요! (100자 이내)"
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
    }
    
    let registerBtn = UIButton().then {
        $0.setTitle("리뷰 등록하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.backgroundColor = UIColor.init(r: 238, g: 98, b: 76)
        $0.layer.cornerRadius = 14
        $0.addTarget(self, action: #selector(onTapRegister), for: .touchUpInside)
    }
    
    
    override func setup() {
        stackView.addArrangedSubview(star1)
        stackView.addArrangedSubview(star2)
        stackView.addArrangedSubview(star3)
        stackView.addArrangedSubview(star4)
        stackView.addArrangedSubview(star5)
        addSubViews(containerView, registerBtn, reviewField, stackView, titleLabel)
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-48)
        }
        
        registerBtn.snp.makeConstraints { (make) in
            make.left.equalTo(containerView).offset(25)
            make.right.equalTo(containerView).offset(-24)
            make.bottom.equalTo(containerView).offset(-24)
            make.height.equalTo(48)
        }
        
        reviewField.snp.makeConstraints { (make) in
            make.left.right.equalTo(registerBtn)
            make.bottom.equalTo(registerBtn.snp.top).offset(-24)
            make.height.equalTo(85)
        }
        
        star1.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(registerBtn)
            make.bottom.equalTo(reviewField.snp.top).offset(-8)
            make.height.equalTo(53)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(registerBtn)
            make.bottom.equalTo(stackView.snp.top).offset(-24)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.top).offset(-24)
        }
    }
    
    @objc func onTapRegister() {
        delegate?.onTapRegister()
    }
}
