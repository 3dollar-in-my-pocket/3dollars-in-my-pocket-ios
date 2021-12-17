import UIKit

final class MyReviewEmptyView: BaseView {
    private let emptyBackground = UIImageView().then {
        $0.image = R.image.img_empty_my_review_background()
        $0.contentMode = .scaleAspectFit
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
        $0.text = R.string.localization.my_review_empty_title()
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.emptyBackground,
            self.emptyContainerView,
            self.emptyImageView,
            self.emptyTitleLabel
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
    }
}
