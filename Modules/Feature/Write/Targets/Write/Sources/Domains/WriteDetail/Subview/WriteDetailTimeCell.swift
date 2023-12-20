import UIKit

import Common
import Model
import DesignSystem

final class WriteDetailTimeCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 72)
    }
    
    private let startTimeField = TimeField()
    
    private let fromLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = Colors.gray100.color
        label.font = Fonts.medium.font(size: 12)
        label.text = "부터"
        return label
    }()
    
    private let endTimeField = TimeField()
    
    private let untilLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = Colors.gray100.color
        label.font = Fonts.medium.font(size: 12)
        label.text = "까지"
        return label
    }()
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
        contentView.addSubViews([
            startTimeField,
            fromLabel,
            endTimeField,
            untilLabel
        ])
    }
    
    override func bindConstraints() {
        startTimeField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview()
            $0.trailing.equalTo(fromLabel.snp.leading).offset(-8)
        }
        
        fromLabel.snp.makeConstraints {
            $0.trailing.equalTo(snp.centerX).offset(-8)
            $0.centerY.equalTo(startTimeField)
        }
        
        endTimeField.snp.makeConstraints {
            $0.leading.equalTo(fromLabel.snp.trailing).offset(8)
            $0.top.equalTo(startTimeField)
            $0.bottom.equalTo(startTimeField)
            $0.trailing.equalTo(untilLabel.snp.leading).offset(-8)
        }
        
        untilLabel.snp.makeConstraints {
            $0.centerY.equalTo(endTimeField)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
}


extension WriteDetailTimeCell {
    final class TimeField: BaseView {
        enum Layout {
            static let height: CGFloat = 44
        }
        
        private let containerView: UIView = {
            let view = UIView()
            view.layer.cornerRadius = 8
            view.backgroundColor = Colors.gray10.color
            
            return view
        }()
        
        private let textField: UITextField = {
            let textField = UITextField()
            textField.textAlignment = .left
            textField.font = Fonts.regular.font(size: 14)
            textField.textColor = Colors.gray100.color
            textField.attributedPlaceholder = NSAttributedString(string: Strings.writeDetailNamePlaceholer, attributes: [.foregroundColor: Colors.gray50.color])
            
            return textField
        }()
        
        override func setup() {
            addSubViews([
                containerView,
                textField
            ])
        }
        
        override func bindConstraints() {
            containerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(Layout.height)
            }
            
            textField.snp.makeConstraints {
                $0.leading.equalTo(containerView).offset(12)
                $0.top.equalTo(containerView).offset(12)
                $0.trailing.equalTo(containerView).offset(-12)
                $0.bottom.equalTo(containerView).offset(-12)
            }
            
            snp.makeConstraints {
                $0.height.equalTo(containerView).priority(.high)
            }
        }
    }
}
