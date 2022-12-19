import UIKit

import RxSwift
import RxCocoa

final class MarkerPopupView: BaseView {
    let backgroundButton = UIButton()
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 30
        $0.backgroundColor = .white
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_close_24"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .extraBold(size: 18)
        $0.textColor = Color.gray100
        $0.textAlignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .regular(size: 16)
        $0.textColor = Color.gray50
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let bottomButton = UIButton().then {
        $0.layer.cornerRadius = 24
        $0.backgroundColor = Color.red
        $0.titleLabel?.font = .bold(size: 16)
    }
    
    override func setup() {
        self.containerView.addSubViews([
            self.imageView,
            self.titleLabel,
            self.descriptionLabel,
            self.bottomButton,
            self.closeButton
        ])
        self.addSubViews([
            self.backgroundButton,
            self.containerView
        ])
    }
    
    override func bindConstraints() {
        self.backgroundButton.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-22)
            make.top.equalTo(self.imageView)
        }
        
        self.bottomButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(24)
            make.right.equalTo(self.containerView).offset(-24)
            make.bottom.equalTo(self.containerView).offset(-24)
            make.height.equalTo(48)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(24)
            make.right.equalTo(self.containerView).offset(-24)
            make.bottom.equalTo(self.bottomButton.snp.top).offset(-24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.descriptionLabel.snp.top).offset(-4)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.titleLabel.snp.top).offset(-24)
            make.height.equalTo(160)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.top.equalTo(self.imageView).offset(24)
            make.right.equalTo(self.imageView).offset(-24)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
    }
    
    fileprivate func bind(advertisement: Advertisement) {
        self.imageView.setImage(urlString: advertisement.imageUrl)
        self.titleLabel.text = advertisement.title
        self.descriptionLabel.text = advertisement.subTitle
        self.bottomButton.setTitle(advertisement.extraContent, for: .normal)
    }
}

extension Reactive where Base: MarkerPopupView {
    var advertisement: Binder<Advertisement> {
        return Binder(self.base) { view, advertisement in
            view.bind(advertisement: advertisement)
        }
    }
}
