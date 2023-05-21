import UIKit

final class VisitBedgeView: BaseView {
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 13
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
    }
    
    private let bedgeImage = UIImageView()
    
    private let countLabel = UILabel().then {
        $0.font = .bold(size: 12)
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.stackView.addArrangedSubview(self.bedgeImage)
        self.stackView.addArrangedSubview(self.countLabel)
        self.addSubViews([
            self.containerView,
            self.stackView
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalTo(self.stackView).offset(-10)
            make.right.equalTo(self.stackView).offset(10)
            make.top.equalTo(self.stackView).offset(-5)
            make.bottom.equalTo(self.stackView).offset(5)
        }
        
        self.stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.bedgeImage.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
                
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.containerView)
        }
    }
    
    func bind(visitHistory: VisitOverview, isDeleted: Bool) {
        if isDeleted {
            self.containerView.backgroundColor = Color.gray60
            self.countLabel.textColor = Color.gray10
            self.bedgeImage.image = UIImage(named: "img_bedge_gray")
        } else {
            self.containerView.backgroundColor = UIColor(r: 0, g: 198, b: 103)
            self.countLabel.textColor = .white
            self.bedgeImage.image = UIImage(named: "img_bedge")
        }
        self.countLabel.text = "\(visitHistory.existsCounts)명"
    }
}
