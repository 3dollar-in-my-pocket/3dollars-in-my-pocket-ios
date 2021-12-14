import UIKit

final class MyVisitHistoryEmptyView: BaseView {
    private let emptyBackground = UIImageView().then {
        $0.image = R.image.img_empty_visit_history_background()
    }
    
    private let emptyContainerView = UIView().then {
        $0.backgroundColor = R.color.gray95()
        $0.layer.cornerRadius = 15
    }
    
    private let emptyImageView = UIImageView().then {
        $0.image = R.image.img_empty_my()
    }
    
    private let emptyTitleLabel = UILabel().then {
        $0.font = .medium(size: 16)
        $0.textColor = R.color.gray30()
        $0.text = R.string.localization.my_visit_history_empty_title()
    }
    
    private let emptyDescriptionLabel = UILabel().then {
        $0.textColor = R.color.gray60()
        $0.font = .regular(size: 12)
        $0.text = R.string.localization.my_visit_history_empty_description()
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.emptyBackground,
            self.emptyContainerView,
            self.emptyImageView,
            self.emptyTitleLabel,
            self.emptyDescriptionLabel
        ])
    }
    
    override func bindConstraints() {
        self.emptyBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.emptyContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        self.emptyImageView.snp.makeConstraints { make in
            make.centerX.equalTo(self.emptyContainerView)
            make.top.equalTo(self.emptyContainerView).offset(24)
            make.width.height.equalTo(100)
        }
        
        self.emptyTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.emptyContainerView)
            make.top.equalTo(self.emptyImageView.snp.bottom).offset(12)
        }
        
        self.emptyDescriptionLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.emptyContainerView)
            make.top.equalTo(self.emptyTitleLabel.snp.bottom).offset(8)
        }
    }
}
