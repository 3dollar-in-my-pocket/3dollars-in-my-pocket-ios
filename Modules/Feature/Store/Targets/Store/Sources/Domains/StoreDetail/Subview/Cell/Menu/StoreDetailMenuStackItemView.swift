import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailMenuStackItemView: BaseView {
    enum Layout {
        static let height: CGFloat = 18
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    override func setup() {
        backgroundColor = .clear
        addSubViews([
            nameLabel,
            priceLabel
        ])
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawDash()
    }
    
    override func bindConstraints() {
        nameLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(36)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(Layout.height)
        }
        
        priceLabel.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.centerY.equalTo(nameLabel)
            $0.height.equalTo(nameLabel)
        }
    }
    
    func bind(_ menu: StoreDetailMenu) {
        nameLabel.text = menu.name
        priceLabel.text = menu.description
    }
    
    private func drawDash() {
        let bzPath = UIBezierPath()
        bzPath.lineWidth = 1
        bzPath.lineCapStyle = .round
        
        let startingPoint = CGPoint(x: nameLabel.frame.maxX + 8, y: nameLabel.frame.midY)
        let endingPoint = CGPoint(x: priceLabel.frame.minX - 8, y: nameLabel.frame.midY)
        
        bzPath.move(to: startingPoint)
        bzPath.addLine(to: endingPoint)
        bzPath.close()
        bzPath.setLineDash([3, 10], count: 2, phase: 0)
        Colors.gray30.color.set()
        bzPath.stroke()
    }
}
