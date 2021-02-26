import UIKit

class RegisteredStoreHeader: BaseView {
    let countLabel = UILabel().then {
        $0.text = "05개"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 24)
        $0.textColor = .white
    }
    
    override func setup() {
        backgroundColor = .clear
        addSubViews(countLabel)
    }
    
    override func bindConstraints() {
        countLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func setCount(count: Int) {
        countLabel.text = String(format: "%d개", count)
    }
}
