import UIKit

import Common
import DesignSystem
import Model

final class MainBannerPopupView: BaseView {
    let bannerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.imageView?.contentMode = .scaleAspectFill
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.contentMode = .scaleAspectFill
        
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.MainBannerPopup.close, for: .normal)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1)
        button.contentVerticalAlignment = .top
        button.contentEdgeInsets = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        button.titleLabel?.font = Fonts.medium.font(size: 16)
        
        return button
    }()
    
    let disableTodayButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.MainBannerPopup.disableToday, for: .normal)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1)
        button.contentVerticalAlignment = .top
        button.contentEdgeInsets = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        button.titleLabel?.font = Fonts.medium.font(size: 16)
        
        return button
    }()
    
    let verticalView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray50.color
        
        return view
    }()
    
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color.withAlphaComponent(0.8)
        addSubViews([
            bannerButton,
            cancelButton,
            disableTodayButton,
            verticalView
        ])
    }
    
    override func bindConstraints() {
        disableTodayButton.snp.makeConstraints {
            $0.left.bottom.equalToSuperview()
            $0.right.equalTo(snp.centerX)
            $0.height.equalTo(67 + UIUtils.bottomSafeAreaInset)
        }
        
        cancelButton.snp.makeConstraints {
            $0.right.bottom.equalToSuperview()
            $0.left.equalTo(snp.centerX)
            $0.height.equalTo(disableTodayButton)
        }
        
        verticalView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
            $0.width.equalTo(1)
            $0.top.equalTo(disableTodayButton).offset(20)
        }
        
        bannerButton.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.bottom.equalTo(disableTodayButton.snp.top)
        }
    }
    
    func bind(advertisement: AdvertisementResponse) {
        bannerButton.setImage(urlString: advertisement.image?.url, state: .normal)
    }
}
