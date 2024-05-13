import UIKit

import Common
import DesignSystem

final class HomeFilterTooltip: BaseView {
    private let triangleView: TriangleView = {
        let view = TriangleView(frame: CGRect(x: 0, y: 0, width: 16, height: 12))
        view.backgroundColor = .clear
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.mainPink.color
        view.layer.cornerRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowColor = Colors.mainPink.color.cgColor
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.semiBold.font(size: 14)
        label.text = Strings.homeFilterTooltipTitle
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.medium.font(size: 12)
        label.numberOfLines = 2
        label.text = Strings.homeFilterTooltipDescription
        label.textAlignment = .left
        label.setLineHeight(lineHeight: 18)
        return label
    }()
    
    override func setup() {
        addSubview(triangleView)
        triangleView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(16)
            $0.height.equalTo(12)
        }
        
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.equalTo(triangleView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview()
        }
        
        snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 251, height: 100))
        }
    }
}

final class TriangleView: UIView {
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.width / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.close()
        
        Colors.mainPink.color.setFill()
        path.fill()
    }
}
