import UIKit

final class VisitBedgeView: BaseView {
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 13
        $0.backgroundColor = UIColor(r: 0, g: 198, b: 103)
    }
    
    private let bedgeImage = UIImageView().then {
        $0.image = R.image.img_bedge()
    }
    
    private let countLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = .white
        $0.text = "10명"
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.containerView,
            self.bedgeImage,
            self.countLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalTo(self.bedgeImage).offset(-10)
            make.right.equalTo(self.countLabel).offset(10)
            make.top.equalTo(self.bedgeImage).offset(-5)
            make.bottom.equalTo(self.bedgeImage).offset(5)
        }
        
        self.bedgeImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        self.countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.bedgeImage)
            make.left.equalTo(self.bedgeImage.snp.right).offset(2)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.containerView).priority(.high)
        }
    }
}
