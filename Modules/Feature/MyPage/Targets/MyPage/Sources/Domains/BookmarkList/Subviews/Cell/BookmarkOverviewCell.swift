import UIKit

import Common
import DesignSystem

final class BookmarkOverviewCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 174
    }
    
    let editButton: UIButton = {
        let button = UIButton()
        let icon = Icons.writeSolid.image.resizeImage(scaledTo: 16).withRenderingMode(.alwaysTemplate)
        
        button.setTitle("수정하기", for: .normal)
        button.setImage(icon, for: .normal)
        button.tintColor = Colors.gray60.color
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        button.setTitleColor(Colors.gray60.color, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.systemWhite.color
        return label
    }()

    private let introductionLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray70.color
        label.numberOfLines = 0
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.gray90.color
        return view
    }()
    
    
    override func setup() {
        contentView.addSubViews([
            editButton,
            titleLabel,
            introductionLabel,
            divider
        ])
    }
    
    override func bindConstraints() {
        editButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(editButton.snp.bottom).offset(12)
            $0.height.equalTo(28)
        }
        
        introductionLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
        
        divider.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.top.equalTo(introductionLabel.snp.bottom).offset(24)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(title: String, introduction: String?) {
        titleLabel.text = title
        
        if let introduction, introduction.isNotEmpty {
            introductionLabel.text = introduction
        } else {
            introductionLabel.text = "리스트에 대한 한줄평을 입력해주세요! 공유 시 사용됩니다."
        }
    }
}
