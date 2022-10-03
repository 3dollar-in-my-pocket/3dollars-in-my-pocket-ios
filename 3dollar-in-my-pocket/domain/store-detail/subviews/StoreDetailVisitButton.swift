import UIKit

import RxSwift
import RxCocoa

final class StoreDetailVisitButton: BaseView {
    private let visitButtonBackground = UIView().then {
        $0.layer.cornerRadius = 37
        
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: 232, height: 64),
            cornerRadius: 37
        ).cgPath
        shadowLayer.fillColor = UIColor.init(r: 255, g: 255, b: 255, a: 0.6).cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = nil
        shadowLayer.shadowOffset = CGSize(width: 0, height: 1)
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.shadowRadius = 10
        $0.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    fileprivate let visitButton = UIButton().then {
        $0.setTitle("store_detail_add_visit_history".localized, for: .normal)
        $0.titleLabel?.font = .bold(size: 16)
        $0.setBackgroundColor(R.color.red() ?? UIColor.red, for: .normal)
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = true
    }
    
    override func setup() {
        self.addSubViews([
            self.visitButtonBackground,
            self.visitButton
        ])
    }
    
    override func bindConstraints() {
        self.visitButtonBackground.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(232)
            make.height.equalTo(64)
        }
        
        self.visitButton.snp.makeConstraints { make in
            make.left.equalTo(visitButtonBackground.snp.left).offset(8)
            make.right.equalTo(visitButtonBackground.snp.right).offset(-8)
            make.top.equalTo(visitButtonBackground.snp.top).offset(8)
            make.bottom.equalTo(visitButtonBackground.snp.bottom).offset(-8)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.visitButtonBackground).priority(.high)
        }
    }
}

extension Reactive where Base: StoreDetailVisitButton {
    var tap: ControlEvent<Void> {
        return self.base.visitButton.rx.tap
    }
}
