import UIKit

import Common
import DesignSystem

final class StoreDetailVisitSummryView: BaseView {
    enum ItemType {
        case success(Int)
        case fail(Int)
    }
    
    enum Layout {
        static let size = CGSize(width: (UIUtils.windowBounds.width - 48) / 2, height: 48)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        
        return view
    }()
    
    private let iconView = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray100.color
        
        return label
    }()
    
    override func setup() {
        containerView.addSubViews([
            iconView,
            titleLabel
        ])
        
        addSubViews([
            containerView
        ])
        bind(.success(1))
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.size.equalTo(Layout.size)
        }
        
        iconView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(22)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(iconView.snp.right).offset(8)
            $0.centerY.equalTo(iconView)
        }
    }
    
    func bind(_ type: ItemType) {
        switch type {
        case .success(let count):
            setTitle(type: type, count: count)
            iconView.image = Icons.faceSmile.image.withTintColor(Colors.mainGreen.color)
            containerView.backgroundColor = Colors.green100.color
            
        case .fail(let count):
            setTitle(type: type, count: count)
            iconView.image = Icons.faceSad.image.withTintColor(Colors.mainRed.color)
            containerView.backgroundColor = Colors.pink100.color
        }
    }
    
    private func setTitle(type: ItemType, count: Int) {
        var title: String
        switch type {
        case .success(let count):
            title = Strings.StoreDetail.Visit.Format.visitSuccess(count)
            
        case .fail(let count):
            title = Strings.StoreDetail.Visit.Format.visitFail(count)
        }
        
        let boldRange = (title as NSString).range(of: "\(count)명")
        let mutableString = NSMutableAttributedString(string: title)
        mutableString.addAttribute(.font, value: Fonts.semiBold.font(size: 14) as Any, range: boldRange)
        titleLabel.attributedText = mutableString
    }
}

