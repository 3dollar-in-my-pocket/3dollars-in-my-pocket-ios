import UIKit

class MenuCell: BaseTableViewCell {
    
    static let registerId = "\(MenuCell.self)"
    
    let nameField = UITextField().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
        $0.layer.borderWidth = 1
        $0.placeholder = "ex)슈크림"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.textColor = UIColor.init(r: 28, g: 28, b: 28)
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
        $0.rightViewMode = .always
        $0.returnKeyType = .done
    }
    
    let descField = UITextField().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
        $0.layer.borderWidth = 1
        $0.placeholder = "ex)3개 2천원"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.textColor = UIColor.init(r: 28, g: 28, b: 28)
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
        $0.rightViewMode = .always
        $0.returnKeyType = .done
    }
    
    override func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        self.contentView.addSubViews(nameField, descField)
        
        nameField.rx.text.bind { [weak self] (inputText) in
            if inputText!.isEmpty {
                self?.nameField.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
            } else {
                self?.nameField.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
            }
        }.disposed(by: disposeBag)
        
        descField.rx.text.bind { [weak self] (inputText) in
            if inputText!.isEmpty {
                self?.descField.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
            } else {
                self?.descField.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
            }
        }.disposed(by: disposeBag)
    }
    
    override func bindConstraints() {
        nameField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.height.equalTo(50)
            make.width.equalTo(106)
        }
        
        descField.snp.makeConstraints { (make) in
            make.left.equalTo(nameField.snp.right).offset(8)
            make.centerY.equalTo(nameField.snp.centerY)
            make.height.equalTo(nameField.snp.height)
            make.right.equalToSuperview().offset(-23)
        }
    }
    
    func setMenu(menu: Menu) {
        self.nameField.text = menu.name
        self.nameField.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
        self.descField.text = menu.price
        self.descField.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
    }
}
