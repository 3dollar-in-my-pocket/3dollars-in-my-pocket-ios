import UIKit
import Combine

import Common
import DesignSystem

final class WriteDetailCategoryHeaderView: BaseCollectionViewReusableView {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray100.color
        $0.text = Strings.writeDetailHeaderCategory
    }
    
    let deleteButton = UIButton().then {
        $0.setTitle(Strings.writeDetailHeaderDeleteAllMenu, for: .normal)
        $0.setTitleColor(Colors.mainRed.color, for: .normal)
        $0.titleLabel?.font = Fonts.bold.font(size: 12)
        $0.setImage(Icons.delete.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.mainRed.color
    }
    
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
                $0.right.equalTo(buttonTitleLabel.snp.left).offset(-4).priority(.high)
                $0.width.height.equalTo(12)
            }
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-20)
        }
    }
}
