import UIKit

final class DeleteMenuButton: UIButton {
    let checkImage = UIImageView().then {
        $0.image = R.image.ic_check()
        $0.isHidden = true
    }
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.borderColor = UIColor(r: 238, g: 98, b: 76).cgColor
            } else {
                self.layer.borderColor = UIColor(r: 228, g: 228, b: 228).cgColor
            }
            self.checkImage.isHidden = !isSelected
        }
    }
    
    private func setup() {
        self.setTitleColor(UIColor(r: 28, g: 28, b: 28), for: .normal)
        self.titleLabel?.font = .bold(size: 16)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        self.contentHorizontalAlignment = .left
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.init(r: 228, g: 228, b: 228).cgColor
        self.layer.cornerRadius = 20
        self.addSubViews(self.checkImage)
    }
    
    private func bindConstraints() {
        self.checkImage.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}
