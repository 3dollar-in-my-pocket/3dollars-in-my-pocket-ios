import UIKit

class MainView: BaseView {
    let stackView = UIStackView().then {
        $0.alignment = .leading
        $0.axis = .horizontal
    }
    
    let stackBg = UIView().then {
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 29
    }
    
    let myPageBtn = UIButton().then {
        $0.setTitle("마이 페이지", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 24
        $0.backgroundColor = .red
    }
    
    let homeBtn = UIButton().then {
        $0.setTitle("홈", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 24
        $0.backgroundColor = .yellow
    }
    
    let writingBtn = UIButton().then {
        $0.setTitle("글쓰기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 24
        $0.backgroundColor = .green
    }
    
    
    override func setup() {
        backgroundColor = .white
        stackView.addArrangedSubview(myPageBtn)
        stackView.addArrangedSubview(homeBtn)
        stackView.addArrangedSubview(writingBtn)
        addSubViews(stackBg, stackView)
    }
    
    override func bindConstraints() {
        
        myPageBtn.snp.makeConstraints { (make) in
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        
        homeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(myPageBtn.snp.right).offset(10)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        
        writingBtn.snp.makeConstraints { (make) in
            make.left.equalTo(homeBtn.snp.right).offset(10)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        
        stackBg.snp.makeConstraints { (make) in
            make.left.equalTo(stackView.snp.left).offset(-20)
            make.top.equalTo(stackView.snp.top).offset(-5)
            make.bottom.equalTo(stackView.snp.bottom).offset(5)
            make.right.equalTo(stackView.snp.right).offset(20)
        }
    }
}
