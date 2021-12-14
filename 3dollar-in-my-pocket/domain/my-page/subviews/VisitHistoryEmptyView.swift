import UIKit

final class VisitHistoryEmptyView: BaseView {
    static let size = CGSize(width: 250, height: 80)
    
    private let containerView = UIView().then {
        $0.backgroundColor = R.color.gray95()
        $0.layer.cornerRadius = 15
    }
    
    private let emptyImage = UIImageView().then {
        $0.image = R.image.img_empty_my()
    }
    
    private let emptyTitleLabel = UILabel().then {
        $0.font = .medium(size: 16)
        $0.textColor = .white
        $0.text = R.string.localization.my_page_visit_history_empty_title()
    }
    
    private let emptyDescriptionLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray30()
        $0.text =  R.string.localization.my_page_visit_history_empty_description()
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.containerView,
            self.emptyImage,
            self.emptyTitleLabel,
            self.emptyDescriptionLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(Self.size)
        }
        
        self.emptyImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(48)
        }
        
        self.emptyTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.emptyImage.snp.right).offset(8)
            make.top.equalTo(self.containerView).offset(20)
            make.right.equalTo(self.containerView).offset(-16)
        }
        
        self.emptyDescriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.emptyTitleLabel)
            make.top.equalTo(self.emptyTitleLabel.snp.bottom).offset(8)
//            make.right.equalTo(self.emptyTitleLabel)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.containerView).priority(.high)
        }
    }
}
