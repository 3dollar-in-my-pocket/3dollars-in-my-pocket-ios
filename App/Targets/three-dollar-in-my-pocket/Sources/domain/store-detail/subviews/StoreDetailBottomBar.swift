import UIKit

import RxSwift
import RxCocoa

final class StoreDetailBottomBar: BaseView {
    fileprivate let bookmarkButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_bookmark_off"), for: .normal)
        $0.setImage(UIImage(named: "ic_bookmark_on"), for: .selected)
        $0.setTitle("store_detail_bookmark".localized, for: .normal)
        $0.titleLabel?.font = .medium(size: 14)
        $0.setTitleColor(Color.red, for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -4)
    }
    
    fileprivate let visitButton = UIButton().then {
        $0.backgroundColor = Color.red
        $0.layer.cornerRadius = 24
        $0.setTitle("store_detail_add_visit_history".localized, for: .normal)
        $0.titleLabel?.font = .bold(size: 16)
        $0.setTitleColor(.white, for: .normal)
    }
    
    override func setup() {
        self.backgroundColor = .white
        self.addSubViews([
            self.bookmarkButton,
            self.visitButton
        ])
    }
    
    override func bindConstraints() {
        self.visitButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(48)
            make.top.equalToSuperview().offset(8)
            make.width.equalTo(240 * RatioUtils.widthRatio)
        }
        
        self.bookmarkButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.visitButton)
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(self.visitButton.snp.left).offset(-20)
        }
        
        self.snp.makeConstraints { make in
            let bottomInset = (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + 8
            
            make.top.equalTo(self.visitButton).offset(-8).priority(.high)
            make.bottom.equalTo(self.visitButton)
                .offset(bottomInset)
                .priority(.high)
        }
    }
}

extension Reactive where Base: StoreDetailBottomBar {
    var isBookmarked: Binder<Bool> {
        return Binder(self.base) { view, isBookmarked in
            view.bookmarkButton.isSelected = isBookmarked
        }
    }
    
    var tapBookmark: ControlEvent<Void> {
        return base.bookmarkButton.rx.tap
    }
    
    var tapVisit: ControlEvent<Void> {
        return base.visitButton.rx.tap
    }
}
