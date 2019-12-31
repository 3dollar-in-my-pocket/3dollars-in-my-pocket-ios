import UIKit

class MainView: BaseView {
    let stackView = UIStackView().then {
        $0.alignment = .leading
        $0.axis = .horizontal
    }
    
    let stackBg = UIView().then {
        $0.backgroundColor = .white
        $0.alpha = 0.6
        $0.layer.cornerRadius = 37
    }
    
    let homeBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "img_home_off"), for: .normal)
        $0.setImage(UIImage.init(named: "img_home_on"), for: .selected)
        $0.adjustsImageWhenHighlighted = false
    }
    
    let writingBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "img_writing_off"), for: .normal)
        $0.setImage(UIImage.init(named: "img_writing_on"), for: .selected)
        $0.adjustsImageWhenHighlighted = false
    }
    
    let myPageBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "img_my_page_off"), for: .normal)
        $0.setImage(UIImage.init(named: "img_my_page_on"), for: .selected)
        $0.adjustsImageWhenHighlighted = false
    }
    
    
    override func setup() {
        backgroundColor = .white
        stackView.addArrangedSubview(homeBtn)
        stackView.addArrangedSubview(writingBtn)
        stackView.addArrangedSubview(myPageBtn)
        addSubViews(stackBg, stackView)
    }
    
    override func bindConstraints() {
        writingBtn.snp.makeConstraints { (make) in
            make.width.equalTo(56)
            make.height.equalTo(56)
            make.centerX.equalToSuperview()
        }
        
        homeBtn.snp.makeConstraints { (make) in
            make.width.equalTo(56)
            make.height.equalTo(56)
            make.right.equalTo(writingBtn.snp.left).offset(-24)
        }
        
        myPageBtn.snp.makeConstraints { (make) in
            make.width.equalTo(56)
            make.height.equalTo(56)
            make.left.equalTo(writingBtn.snp.right).offset(24)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-32)
            make.centerX.equalToSuperview()
        }
        
        stackBg.snp.makeConstraints { (make) in
            make.left.equalTo(stackView.snp.left).offset(-8)
            make.top.equalTo(stackView.snp.top).offset(-8)
            make.bottom.equalTo(stackView.snp.bottom).offset(8)
            make.right.equalTo(stackView.snp.right).offset(8)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupStackViewShadow()
    }
    
    private func setupStackViewShadow() {
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: stackBg.bounds, cornerRadius: 37).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.1
        shadowLayer.shadowRadius = 20
        
        stackBg.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func selectBtn(index: Int) {
        for buttonIndex in stackView.arrangedSubviews.indices {
            if let button = stackView.arrangedSubviews[buttonIndex] as? UIButton {
                button.isSelected = (buttonIndex == index)
            }
        }
    }
}
