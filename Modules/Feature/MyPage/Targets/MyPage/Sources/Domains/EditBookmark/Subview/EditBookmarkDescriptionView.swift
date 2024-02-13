import UIKit
import Combine

import Common
import DesignSystem

final class EditBookmarkDescriptionView: BaseView {
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
    
    private let descriptionField: UITextView = {
        let descriptionField = UITextView()
        
        descriptionField.font = Fonts.medium.font(size: 12)
        descriptionField.textColor = Colors.gray0.color
        descriptionField.tintColor = Colors.mainPink.color
        descriptionField.backgroundColor = .clear
        return descriptionField
    }()
    
    override func setup() {
        addSubViews([
            titleLabel,
            countLabel,
            containerView,
            descriptionField
        ])
        
        descriptionField.delegate = self
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
            $0.height.equalTo(104)
            $0.bottom.equalToSuperview()
        }
        
        descriptionField.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(12)
            $0.trailing.equalTo(containerView).offset(-12)
            $0.top.equalTo(containerView).offset(12)
            $0.bottom.equalTo(containerView).offset(-12)
        }
        
        snp.makeConstraints {
            $0.top.equalTo(titleLabel).priority(.high)
            $0.bottom.equalTo(containerView).priority(.high)
        }
    }
    
    func bind(description: String) {
        if description.isEmpty {
            descriptionField.text = "리스트에 대한 한줄평을 입력해주세요! 공유 시 사용됩니다."
            descriptionField.textColor = Colors.gray70.color
            setCount(0)
        } else {
            descriptionField.text = description
            descriptionField.textColor = Colors.systemWhite.color
            setCount(description.count)
        }
    }
    
    private func setCount(_ count: Int) {
        let text = "\(count)/150"
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

extension EditBookmarkDescriptionView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard let textFieldText = textView.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
          return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + text.count
        var newLinesCount = textFieldText.components(separatedBy: CharacterSet.newlines).count - 1
        
        if text == "\n" {
            newLinesCount += 1
        }
        
        return count <= 150 && newLinesCount < 6
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        
        setCount(text.count)
        onTextChange.send(text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let text = textView.text ?? ""
        
        if text == "리스트에 대한 한줄평을 입력해주세요! 공유 시 사용됩니다." {
            textView.text = ""
            textView.textColor = Colors.systemWhite.color
        } else {
            onTextChange.send(text)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text ?? ""
        
        if text.isEmpty {
            textView.textColor = Colors.gray70.color
            textView.text = "리스트에 대한 한줄평을 입력해주세요! 공유 시 사용됩니다."
        }
    }
}
