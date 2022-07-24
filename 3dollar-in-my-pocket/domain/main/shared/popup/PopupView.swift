import UIKit

final class PopupView: BaseView {
    
    let bannerButton = UIButton().then {
        $0.backgroundColor = .gray
        $0.imageView?.contentMode = .scaleAspectFill
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.contentMode = .scaleAspectFill
    }
    
    let cancelButton = UIButton().then {
        $0.setTitle(R.string.localization.popup_close(), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(r: 44, g: 44, b: 44)
        $0.contentVerticalAlignment = .top
        $0.contentEdgeInsets = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        $0.titleLabel?.font = .medium(size: 16)
    }
    
    let disableTodayButton = UIButton().then {
        $0.setTitle(R.string.localization.popup_disable_today(), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(r: 44, g: 44, b: 44)
        $0.contentVerticalAlignment = .top
        $0.contentEdgeInsets = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        $0.titleLabel?.font = .medium(size: 16)
    }
    
    let verticalView = UIView().then {
        $0.backgroundColor = UIColor(r: 149, g: 149, b: 149)
    }
    
    
    override func setup() {
        self.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.8)
        self.addSubViews([
            self.bannerButton,
            self.cancelButton,
            self.disableTodayButton,
            self.verticalView
        ])
    }
    
    override func bindConstraints() {
        self.disableTodayButton.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.right.equalTo(self.snp.centerX)
            make.height.equalTo(
                67 + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
            )
        }
        
        self.cancelButton.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.left.equalTo(self.snp.centerX)
            make.height.equalTo(self.disableTodayButton)
        }
        
        self.verticalView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(1)
            make.top.equalTo(disableTodayButton).offset(20)
        }
        
        self.bannerButton.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(disableTodayButton.snp.top)
        }
    }
    
    func bind(advertisement: Advertisement) {
        bannerButton.kf.setImage(with: URL.init(string: advertisement.imageUrl), for: .normal)
    }
}
