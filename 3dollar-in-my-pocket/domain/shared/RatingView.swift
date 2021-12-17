import UIKit

final class RatingView: BaseView {
    private let star1 = UIButton().then {
        $0.setImage(R.image.ic_star_on(), for: .selected)
        $0.setImage(R.image.ic_star_off(), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    private let star2 = UIButton().then {
        $0.setImage(R.image.ic_star_on(), for: .selected)
        $0.setImage(R.image.ic_star_off(), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    private let star3 = UIButton().then {
        $0.setImage(R.image.ic_star_on(), for: .selected)
        $0.setImage(R.image.ic_star_off(), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    private let star4 = UIButton().then {
        $0.setImage(R.image.ic_star_on(), for: .selected)
        $0.setImage(R.image.ic_star_off(), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    private let star5 = UIButton().then {
        $0.setImage(R.image.ic_star_on(), for: .selected)
        $0.setImage(R.image.ic_star_off(), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.backgroundColor = .clear
        $0.spacing = 2
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.stackView.addArrangedSubview(self.star1)
        self.stackView.addArrangedSubview(self.star2)
        self.stackView.addArrangedSubview(self.star3)
        self.stackView.addArrangedSubview(self.star4)
        self.stackView.addArrangedSubview(self.star5)
        self.addSubViews([
            self.stackView
        ])
    }
    
    override func bindConstraints() {
        self.star1.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
        }
        
        self.star2.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
        }
        
        self.star3.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
        }
        
        self.star4.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
        }
        self.star5.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
        }
        
        self.stackView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(14)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.stackView).priority(.high)
        }
    }
    
    func bind(rating: Int) {
        for index in 0...stackView.arrangedSubviews.count - 1 {
            if let star = stackView.arrangedSubviews[index] as? UIButton {
                star.isSelected = index < rating
            }
        }
    }
}
