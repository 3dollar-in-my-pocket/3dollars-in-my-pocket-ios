import UIKit

protocol ReviewModalViewDelegate: class {
    func onTapRegister()
    
    func onTapClose()
}

class ReviewModalView: BaseView {
    
    weak var delegate: ReviewModalViewDelegate?
    var rating = 0
    
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
    
    let closeBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_close_24"), for: .normal)
        $0.addTarget(self, action: #selector(onTapClose), for: .touchUpInside)
    }
    
    let star1 = UIButton().then {
        $0.imageView?.contentMode = .scaleAspectFill
        $0.setImage(UIImage.init(named: "ic_star_32_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_32_off"), for: .normal)
        $0.addTarget(self, action: #selector(onTapStar1), for: .touchUpInside)
        $0.showsTouchWhenHighlighted = false
    }
    
    let star2 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_32_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_32_off"), for: .normal)
        $0.addTarget(self, action: #selector(onTapStar2), for: .touchUpInside)
    }
    
    let star3 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_32_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_32_off"), for: .normal)
        $0.addTarget(self, action: #selector(onTapStar3), for: .touchUpInside)
    }
    
    let star4 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_32_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_32_off"), for: .normal)
        $0.addTarget(self, action: #selector(onTapStar4), for: .touchUpInside)
    }
    
    let star5 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_32_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_32_off"), for: .normal)
        $0.addTarget(self, action: #selector(onTapStar5), for: .touchUpInside)
    }
    
    let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.backgroundColor = .clear
        $0.spacing = 8
    }
    
    let stackContainer = UIView().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
        $0.layer.borderWidth = 1
    }
    
    let reviewTextView = UITextView().then {
        $0.text = "리뷰를 남겨주세요! (100자 이내)"
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
        $0.contentInset = UIEdgeInsets(top: 8, left: 5, bottom: 10, right: 0)
        $0.backgroundColor = .clear
        $0.textColor = UIColor.init(r: 200, g: 200, b: 200)
        $0.returnKeyType = .done
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
        addSubViews(containerView, registerBtn, reviewTextView, stackContainer, stackView, titleLabel, closeBtn)
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
        
        reviewTextView.snp.makeConstraints { (make) in
            make.left.right.equalTo(registerBtn)
            make.bottom.equalTo(registerBtn.snp.top).offset(-24)
            make.height.equalTo(85)
        }
        
        stackContainer.snp.makeConstraints { (make) in
            make.left.right.equalTo(registerBtn)
            make.bottom.equalTo(reviewTextView.snp.top).offset(-8)
            make.height.equalTo(53)
        }
        
        star1.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        star2.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        star3.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        star4.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        star5.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(stackContainer)
            make.left.equalTo(stackContainer).offset(16)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(registerBtn)
            make.bottom.equalTo(stackView.snp.top).offset(-24)
        }
        
        closeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel)
            make.right.equalTo(registerBtn)
            make.width.height.equalTo(24)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.top).offset(-24)
        }
    }
    
    private func onTapStackView(tappedIndex: Int) {
        rating = tappedIndex + 1
        stackContainer.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
        for index in stackView.arrangedSubviews.indices {
            if let button = stackView.arrangedSubviews[index] as? UIButton {
                button.isSelected = (index <= tappedIndex)
            }
        }
    }
    
    @objc func onTapClose() {
        delegate?.onTapClose()
    }
    
    @objc func onTapRegister() {
        delegate?.onTapRegister()
    }
    
    @objc func onTapStar1() {
        onTapStackView(tappedIndex: 0)
    }
    
    @objc func onTapStar2() {
        onTapStackView(tappedIndex: 1)
    }
    
    @objc func onTapStar3() {
        onTapStackView(tappedIndex: 2)
    }
    
    @objc func onTapStar4() {
        onTapStackView(tappedIndex: 3)
    }
    
    @objc func onTapStar5() {
        onTapStackView(tappedIndex: 4)
    }
}
