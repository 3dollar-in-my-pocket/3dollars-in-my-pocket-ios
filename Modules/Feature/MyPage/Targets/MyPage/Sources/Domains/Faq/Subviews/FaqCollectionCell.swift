import UIKit

import Common
import DesignSystem
import Model

final class FaqCollectionCell: BaseCollectionViewCell {
    enum Layout {
        static func calculateSize(faq: FaqResponse) -> CGSize {
            let style = NSMutableParagraphStyle()
            style.maximumLineHeight = 20
            style.minimumLineHeight = 20
            
            let questionHeight = NSString(string: faq.question).boundingRect(
                with: CGSize(width: UIUtils.windowBounds.width - 110, height: CGFloat.greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [
                    .font: Fonts.semiBold.font(size: 14),
                    .paragraphStyle: style
                ],
                context: nil
            ).height
            let answserHeight = NSString(string: faq.answer).boundingRect(
                with: CGSize(width: UIUtils.windowBounds.width - 110, height: CGFloat.greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [
                    .font: Fonts.semiBold.font(size: 14),
                    .paragraphStyle: style,
                ],
                context: nil
            ).height
            
            let height = questionHeight + answserHeight + 40
            return CGSize(width: UIUtils.windowBounds.width, height: height)
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 16
        view.backgroundColor = Colors.gray95.color
        return view
    }()
    
    private let questionMarkLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.pink300.color
        label.text = "Q."
        label.setLineHeight(lineHeight: 20)
        return label
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.pink300.color
        label.numberOfLines = 0
        return label
    }()
    
    private let answerLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.systemWhite.color
        label.numberOfLines = 0
        return label
    }()
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            questionMarkLabel,
            questionLabel,
            answerLabel
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20).priority(.high)
            $0.trailing.equalToSuperview().offset(-20).priority(.high)
            $0.top.equalToSuperview()
            $0.bottom.equalTo(answerLabel).offset(16)
            $0.bottom.equalToSuperview()
        }
        
        questionMarkLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(16)
            $0.top.equalTo(containerView).offset(16)
            $0.width.equalTo(15)
        }
        
        questionLabel.snp.makeConstraints {
            $0.leading.equalTo(questionMarkLabel.snp.trailing).offset(8)
            $0.top.equalTo(questionMarkLabel)
            $0.trailing.equalTo(containerView).offset(-16)
        }
        
        answerLabel.snp.makeConstraints {
            $0.leading.equalTo(questionLabel)
            $0.trailing.equalTo(questionLabel)
            $0.top.equalTo(questionLabel.snp.bottom).offset(8)
        }
    }
    
    func bind(faq: FaqResponse) {
        questionLabel.text = faq.question
        questionLabel.setLineHeight(lineHeight: 20)
        answerLabel.text = faq.answer
        answerLabel.setLineHeight(lineHeight: 20)
    }
}
