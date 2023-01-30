import UIKit

final class BookmarkViewerHeaderView: BaseCollectionReusableView {
    private let titleLabel = UILabel().then {
        $0.text = "나만의 소중한\n음식플리ㅋㅎ"
        $0.font = .bold(size: 30)
        $0.numberOfLines = 0
        $0.textColor = .white
    }
    
    private let senderContainerView = UIView().then {
        $0.backgroundColor = Color.gray90
        $0.layer.cornerRadius = 16
    }
    
    private let medalStackView = UIStackView().then {
        $0.spacing = 5
        $0.axis = .horizontal
    }
    
    private let medalImageView = UIImageView().then {
        $0.backgroundColor = .green
    }
    
    private let medalLabel = UILabel().then {
        $0.textColor = .white
        $0.text = "따끈따끈한 뉴비"
        $0.font = .regular(size: 12)
    }
    
    private let bookmarkTitleLabel = UILabel().then {
        $0.text = "마포구 몽키스패너님의 즐겨찾기"
        $0.font = .regular(size: 16)
        $0.textColor = .white
    }
    
    private let bookmarkDescriptionLabel = UILabel().then {
        $0.text = "제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 "
        $0.textColor = Color.gray40
        $0.numberOfLines = 0
        $0.font = .regular(size: 12)
    }
    
    private let backgroundContainerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.backgroundColor = Color.gray95
    }
    
    private let countLabel = UILabel().then {
        $0.text = "n개의 리스트"
        $0.font = .bold(size: 12)
        $0.textColor = Color.gray20
    }
    
    override func setup() {
        self.medalStackView.addArrangedSubview(self.medalImageView)
        self.medalStackView.addArrangedSubview(self.medalLabel)
        self.addSubViews([
            self.backgroundContainerView,
            self.titleLabel,
            self.senderContainerView,
            self.medalStackView,
            self.bookmarkTitleLabel,
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
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.backgroundContainerView).offset(19)
        }
        
        self.senderContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
            make.bottom.equalTo(self.bookmarkTitleLabel).offset(11)
        }
        
        self.medalImageView.snp.makeConstraints { make in
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.medalStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.senderContainerView).offset(12)
        }
        
        self.bookmarkTitleLabel.snp.makeConstraints { make in
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
}
