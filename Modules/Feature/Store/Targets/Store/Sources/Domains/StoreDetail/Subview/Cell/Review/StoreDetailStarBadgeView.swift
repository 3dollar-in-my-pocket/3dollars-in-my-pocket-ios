import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailStarBadgeView: BaseView {
    enum Layout {
        static let size = CGSize(width: 68, height: 20)
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.pink100.color
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        
        return stackView
    }()
    
    override func setup() {
        addSubViews([
            containerView,
            stackView
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.right.equalTo(stackView).offset(4)
            $0.bottom.equalTo(stackView).offset(4)
        }
        
        stackView.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(4)
            $0.top.equalTo(containerView).offset(4)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
    }
    
    func prepareForReuse() {
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    func bind(_ rating: Int) {
        for index in 0..<5 {
            if rating >= index {
                let starImageView = UIImageView(image: Icons.starSolid.image.withTintColor(Colors.mainPink.color))
                starImageView.snp.makeConstraints {
                    $0.size.equalTo(12)
                }
                
                stackView.addArrangedSubview(starImageView)
            } else {
                let starImageView = UIImageView(image: Icons.starSolid.image.withTintColor(Colors.pink200.color))
                starImageView.snp.makeConstraints {
                    $0.size.equalTo(12)
                }
                
                stackView.addArrangedSubview(starImageView)
            }
        }
    }
}

