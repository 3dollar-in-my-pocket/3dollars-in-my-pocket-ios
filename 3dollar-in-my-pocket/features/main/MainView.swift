import UIKit

class MainView: BaseView {
    let stackView = UIStackView().then {
        $0.alignment = .leading
        $0.axis = .horizontal
    }
    
    let stackBg = UIView().then {
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
        setupStackViewShadow()
        addSubViews(stackBg, stackView)
    }
    
    override func bindConstraints() {
        writingBtn.snp.makeConstraints { (make) in
            make.width.equalTo(56 * RadioUtils.height)
            make.height.equalTo(56 * RadioUtils.height)
            make.centerX.equalToSuperview()
        }
        
        homeBtn.snp.makeConstraints { (make) in
            make.width.equalTo(56 * RadioUtils.height)
            make.height.equalTo(56 * RadioUtils.height)
            make.right.equalTo(writingBtn.snp.left).offset(-24 * RadioUtils.width)
        }
        
        myPageBtn.snp.makeConstraints { (make) in
            make.width.equalTo(56 * RadioUtils.height)
            make.height.equalTo(56 * RadioUtils.height)
            make.left.equalTo(writingBtn.snp.right).offset(24 * RadioUtils.width)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-32 * RadioUtils.height)
            make.centerX.equalToSuperview()
        }
        
        stackBg.snp.makeConstraints { (make) in
            make.left.equalTo(stackView.snp.left).offset(-8 * RadioUtils.width)
            make.top.equalTo(stackView.snp.top).offset(-8 * RadioUtils.width)
            make.bottom.equalTo(stackView.snp.bottom).offset(8 * RadioUtils.width)
            make.right.equalTo(stackView.snp.right).offset(8 * RadioUtils.width)
        }
    }
    
    private func setupStackViewShadow() {
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 232, height: 72), cornerRadius: 37).cgPath
        shadowLayer.fillColor = UIColor.init(r: 255, g: 255, b: 255, a: 0.4).cgColor
        
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
    
    func showTabBar() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.stackBg.alpha = 1
                self?.stackBg.isUserInteractionEnabled = true
                self?.stackView.alpha = 1
                self?.stackView.isUserInteractionEnabled = true
            }, completion: nil)
        }
    }
    
    func hideTabBar() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.stackView.alpha = 0
                self?.stackView.isUserInteractionEnabled = false
                self?.stackBg.alpha = 0
                self?.stackBg.isUserInteractionEnabled = false
            }, completion: nil)
        }
    }
}
