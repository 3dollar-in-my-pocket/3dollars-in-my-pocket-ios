import UIKit

import RxSwift
import RxCocoa

final class BossStoreDetailBottomBar: BaseView {
    fileprivate let bookmarkButton = UIButton().then {
        $0.setImage(R.image.ic_bookmark_off()?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.setImage(R.image.ic_bookmark_on()?.withRenderingMode(.alwaysTemplate), for: .selected)
        $0.setTitle(R.string.localization.store_detail_bookmark(), for: .normal)
        $0.titleLabel?.font = .medium(size: 14)
        $0.setTitleColor(R.color.green(), for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -4)
        $0.tintColor = R.color.green()
    }
    
    fileprivate let feedbackButton = UIButton().then {
        $0.backgroundColor = R.color.green()
        $0.layer.cornerRadius = 24
        $0.setTitle(R.string.localization.boss_store_feedback(), for: .normal)
        $0.titleLabel?.font = .bold(size: 16)
        $0.setTitleColor(.white, for: .normal)
    }
    
    override func setup() {
        self.backgroundColor = .white
        self.addSubViews([
            self.bookmarkButton,
            self.feedbackButton
        ])
    }
    
    override func bindConstraints() {
        self.feedbackButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(48)
            make.top.equalToSuperview().offset(8)
            make.width.equalTo(240 * RatioUtils.widthRatio)
        }
        
        self.bookmarkButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.feedbackButton)
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(self.feedbackButton.snp.left).offset(-20)
        }
        
        self.snp.makeConstraints { make in
            let bottomInset = (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + 8
            
            make.top.equalTo(self.feedbackButton).offset(-8).priority(.high)
            make.bottom.equalTo(self.feedbackButton)
                .offset(bottomInset)
                .priority(.high)
        }
    }
}

extension Reactive where Base: BossStoreDetailBottomBar {
    var isBookmarked: Binder<Bool> {
        return Binder(self.base) { view, isBookmarked in
            view.bookmarkButton.isSelected = isBookmarked
        }
    }
    
    var tapBookmark: ControlEvent<Void> {
        return base.bookmarkButton.rx.tap
    }
    
    var tapFeedback: ControlEvent<Void> {
        return base.feedbackButton.rx.tap
    }
}
