import UIKit
import Combine

import Common
import DesignSystem

final class WriteDetailCategoryHeaderView: BaseCollectionViewReusableView {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.semiBold.font(size: 14)
        titleLabel.textColor = Colors.gray100.color
        titleLabel.text = Strings.writeDetailHeaderCategory
        return titleLabel
    }()
    
    let deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.setTitle(Strings.writeDetailHeaderDeleteAllMenu, for: .normal)
        deleteButton.setTitleColor(Colors.mainRed.color, for: .normal)
        deleteButton.titleLabel?.font = Fonts.bold.font(size: 12)
        deleteButton.setImage(Icons.delete.image.withRenderingMode(.alwaysTemplate), for: .normal)
        deleteButton.tintColor = Colors.mainRed.color
        return deleteButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        backgroundColor = Colors.gray0.color
        addSubViews([
            titleLabel,
            deleteButton
        ])
    }
    
    override func bindConstraints() {
        if let buttonTitleLabel = deleteButton.titleLabel {
            deleteButton.imageView?.snp.makeConstraints {
                $0.centerY.equalTo(buttonTitleLabel)
                $0.trailing.equalTo(buttonTitleLabel.snp.leading).offset(-4).priority(.high)
                $0.width.height.equalTo(12)
            }
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}
