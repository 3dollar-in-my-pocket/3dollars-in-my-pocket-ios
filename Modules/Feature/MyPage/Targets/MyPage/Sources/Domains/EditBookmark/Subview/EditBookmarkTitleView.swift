import UIKit
import Combine

import Common
import DesignSystem

final class EditBookmarkTitleView: BaseView {
    var onTextChange = PassthroughSubject<String, Never>()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        
        titleLabel.font = Fonts.semiBold.font(size: 14)
        titleLabel.textColor = Colors.systemWhite.color
        titleLabel.text = "즐겨찾기 제목"
        return titleLabel
    }()
    
    private let countLabel: UILabel = {
        let countLabel = UILabel()
        
        countLabel.font = Fonts.medium.font(size: 12)
        countLabel.textColor = Colors.systemWhite.color
        return countLabel
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.gray90.color
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let titleField: UITextField = {
        let titleField = UITextField()
        
        titleField.font = Fonts.medium.font(size: 12)
        titleField.textColor = Colors.gray0.color
        titleField.tintColor = Colors.mainPink.color
        return titleField
    }()
    
    override func setup() {
        addSubViews([
            titleLabel,
            countLabel,
            containerView,
            titleField
        ])
        
        titleField.controlPublisher(for: .editingChanged)
            .withUnretained(self)
            .sink(receiveValue: { (owner: EditBookmarkTitleView, _) in
                let text = owner.titleField.text ?? ""
                
                owner.onTextChange.send(text)
                owner.setCount(text.count)
            })
            .store(in: &cancellables)
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(11)
            $0.height.equalTo(42)
            $0.bottom.equalToSuperview()
        }
        
        titleField.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(12)
            $0.trailing.equalTo(containerView).offset(-12)
            $0.centerY.equalTo(containerView)
        }
        
        snp.makeConstraints {
            $0.top.equalTo(titleLabel).priority(.high)
            $0.bottom.equalTo(containerView).priority(.high)
        }
    }
    
    func bind(title: String) {
        titleField.text = title
        setCount(title.count)
    }
    
    private func setCount(_ count: Int) {
        let text = "\(count)/20"
        let range = (text as NSString).range(of: "\(count)")
        let attributesString = NSMutableAttributedString(string: text)
        
        attributesString.addAttribute(
            .foregroundColor,
            value: Colors.mainPink.color,
            range: range
        )
        
        countLabel.attributedText = attributesString
    }
}
