import UIKit

final class StoreDetailMenuView: BaseView {
  
  let nameLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    $0.textColor = .black
    $0.textAlignment = .left
  }
  
  let priceLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Light", size: 14)
    $0.textColor = .black
    $0.textAlignment = .right
  }
  
  
  override func setup() {
    backgroundColor = .clear
    addSubViews(nameLabel, priceLabel)
  }
  
  override func bindConstraints() {
    self.nameLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(48)
      make.top.equalToSuperview().offset(5)
      make.bottom.equalToSuperview().offset(-5)
    }
    
    self.priceLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-16)
      make.centerY.equalTo(self.nameLabel)
    }
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    self.drawDash()
  }
  
  func bind(menu: Menu) {
    self.nameLabel.text = menu.name
    self.priceLabel.text = menu.price
    self.drawDash()
  }
  
  private func drawDash() {
    let bzPath = UIBezierPath()
    bzPath.lineWidth = 1
    bzPath.lineCapStyle = .round

    let startingPoint = CGPoint(x: self.nameLabel.frame.maxX + 8, y: self.nameLabel.frame.midY)
    let endingPoint = CGPoint(x: self.priceLabel.frame.minX - 8, y: self.nameLabel.frame.midY)

    bzPath.move(to: startingPoint)
    bzPath.addLine(to: endingPoint)
    bzPath.close()
    bzPath.setLineDash([3, 10], count: 2, phase: 0)
    UIColor(r: 226, g: 226, b: 226).set()
    bzPath.stroke()
  }
}
