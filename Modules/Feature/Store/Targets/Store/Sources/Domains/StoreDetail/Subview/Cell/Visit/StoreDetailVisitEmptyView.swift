import UIKit

import Common
import DesignSystem

final class StoreDetailVisitEmptyView: BaseView {
    enum Layout {
        static let height: CGFloat = 112
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray100.color
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray0.color
        label.font = Fonts.bold.font(size: 16)
        
        let string = Strings.StoreDetail.Visit.Empty.title
        let attributedString = NSMutableAttributedString(string: string)
        let colorRange = NSString(string: string).range(of: "가게의 최근 활동")
        attributedString.addAttribute(.foregroundColor, value: Colors.mainPink.color, range: colorRange)
        
        label.attributedText = attributedString
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.StoreDetail.Visit.Empty.description
        label.numberOfLines = 2
        label.textColor = Colors.gray60.color
        label.font = Fonts.medium.font(size: 12)
        label.setLineHeight(lineHeight: 18)
        label.textAlignment = .center
        return label
    }()
    
    override func setup() {
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(26)
            $0.trailing.equalToSuperview().offset(-26)
            $0.top.equalToSuperview().offset(24)
        }
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }
}
