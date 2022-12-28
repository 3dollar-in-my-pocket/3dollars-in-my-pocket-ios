import UIKit

import RxSwift
import RxCocoa

final class BossStoreMoreMenuCell: BaseCollectionViewCell {
    static let registerId = "\(BossStoreMoreMenuCell.self)"
    static let height: CGFloat = 48
    
    fileprivate let tapGesture = UITapGestureRecognizer()
    
    private let containerView = UIView().then {
        $0.backgroundColor = Color.gray5
        $0.layer.cornerRadius = 16
    }
    
    private let bottomArrowImage = UIImageView().then {
        $0.image = UIImage(named: "ic_arrow_bottom")
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = Color.gray40
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = -8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.bottomArrowImage,
            self.titleLabel,
            self.stackView
        ])
        self.addGestureRecognizer(self.tapGesture)
        self.contentView.isUserInteractionEnabled = true
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(4)
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
        
        self.bottomArrowImage.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.centerY.equalTo(self.containerView)
            make.width.equalTo(14)
            make.height.equalTo(14)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.bottomArrowImage.snp.right).offset(8)
            make.centerY.equalTo(self.containerView)
        }
        
        self.stackView.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.containerView).offset(-16)
        }
    }
    
    func bind(menus: [BossStoreMenu]) {
        self.titleLabel.text = String.init(
            format: String(format: "localization.boss_store_more_menu".localized, menus.count)
        )
        
        for menu in menus {
            let photoView = self.generatePhotoView(menu: menu)

            self.stackView.addArrangedSubview(photoView)
        }
    }
    
    private func generatePhotoView(menu: BossStoreMenu) -> UIImageView {
        let photoView = UIImageView()

        photoView.layer.cornerRadius = 14
        photoView.layer.masksToBounds = true
        photoView.setImage(urlString: menu.imageUrl)
        photoView.snp.makeConstraints { make in
            make.width.equalTo(28)
            make.height.equalTo(28)
        }

        return photoView
    }
}

extension Reactive where Base: BossStoreMoreMenuCell {
    var tap: ControlEvent<Void> {
        return ControlEvent(events: base.tapGesture.rx.event.map { _ in () })
    }
}
