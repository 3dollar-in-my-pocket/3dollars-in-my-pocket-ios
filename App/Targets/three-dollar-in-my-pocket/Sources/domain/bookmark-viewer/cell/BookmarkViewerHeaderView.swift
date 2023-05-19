import UIKit

import RxSwift
import RxCocoa

final class BookmarkViewerHeaderView: BaseCollectionReusableView {
    private let bookmarkTitleLabel = UILabel().then {
        $0.font = .bold(size: 30)
        $0.numberOfLines = 0
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let senderContainerView = UIView().then {
        $0.backgroundColor = Color.gray90
        $0.layer.cornerRadius = 16
    }
    
    private let medalStackView = UIStackView().then {
        $0.spacing = 5
        $0.axis = .horizontal
    }
    
    private let medalImageView = UIImageView()
    
    private let medalLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .regular(size: 12)
    }
    
    private let userNameLabel = UILabel().then {
        $0.font = .regular(size: 16)
        $0.textColor = .white
    }
    
    private let bookmarkDescriptionLabel = UILabel().then {
        $0.textColor = Color.gray40
        $0.numberOfLines = 0
        $0.font = .regular(size: 12)
    }
    
    private let backgroundContainerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.backgroundColor = Color.gray95
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    private let countLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = Color.gray20
    }
    
    override func setup() {
        self.medalStackView.addArrangedSubview(self.medalImageView)
        self.medalStackView.addArrangedSubview(self.medalLabel)
        self.addSubViews([
            self.backgroundContainerView,
            self.bookmarkTitleLabel,
            self.senderContainerView,
            self.medalStackView,
            self.userNameLabel,
            self.bookmarkDescriptionLabel,
            self.countLabel
        ])
    }
    
    override func bindConstraints() {
        self.backgroundContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.bookmarkDescriptionLabel).offset(35)
        }
        
        self.bookmarkTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.backgroundContainerView).offset(19)
        }
        
        self.senderContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.bookmarkTitleLabel.snp.bottom).offset(16)
            make.bottom.equalTo(self.userNameLabel).offset(11)
        }
        
        self.medalImageView.snp.makeConstraints { make in
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.medalStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.senderContainerView).offset(12)
        }
        
        self.userNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.medalStackView.snp.bottom).offset(6)
        }
        
        self.bookmarkDescriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.senderContainerView.snp.bottom).offset(18)
        }
        
        self.countLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.backgroundContainerView.snp.bottom).offset(28)
            make.bottom.equalToSuperview().offset(-14)
        }
    }
    
    fileprivate func bind(user: User) {
        self.medalImageView.setImage(urlString: user.medal.iconUrl)
        self.medalLabel.text = user.medal.name
        self.setUserNickname(name: user.name)
    }
    
    fileprivate func bind(title: String) {
        self.bookmarkTitleLabel.text = title
    }
    
    fileprivate func bind(description: String) {
        self.bookmarkDescriptionLabel.text = description
    }
    
    fileprivate func bind(totalCount: Int) {
        self.countLabel.text = String(format: "bookmark_viewer_count_format".localized, totalCount)
    }
    
    private func setUserNickname(name: String) {
        let text = String(format: "bookmark_viewer_name_format".localized, name)
        let attributedText = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: name)
        
        attributedText.addAttribute(.font, value: UIFont.bold(size: 16) as Any, range: range)
        self.userNameLabel.attributedText = attributedText
    }
}

extension Reactive where Base: BookmarkViewerHeaderView {
    var user: Binder<User> {
        return Binder(self.base) { view, user in
            view.bind(user: user)
        }
    }
    
    var title: Binder<String> {
        return Binder(self.base) { view, title in
            view.bind(title: title)
        }
    }
    
    var description: Binder<String> {
        return Binder(self.base) { view, description in
            view.bind(description: description)
        }
    }
    
    var totalCount: Binder<Int> {
        return Binder(self.base) { view, totalCount in
            view.bind(totalCount: totalCount)
        }
    }
}
