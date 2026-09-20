import UIKit
import Combine

import Common
import DesignSystem

final class ReportReviewReasonDetailCell: BaseCollectionViewCell {

    let didChangeText = PassthroughSubject<String, Never>()

    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width - 40, height: 80)

        enum Placeholder {
            static let text = Strings.ReportReviewBottomSheet.placeholder
            static let color = Colors.gray40.color
        }

        static let textColor = Colors.gray100.color
    }

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = Colors.gray10.color
        textView.layer.cornerRadius = 12
        textView.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        textView.text = Layout.Placeholder.text
        textView.textColor = Layout.Placeholder.color
        textView.font = Fonts.regular.font(size: 14)
        textView.keyboardDismissMode = .onDrag
        textView.returnKeyType = .done
        textView.delegate = self
        return textView
    }()

    override func setup() {
        super.setup()

        contentView.addSubViews([
            textView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        textView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ReportReviewReasonDetailCell: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.layer.borderColor = Colors.mainPink.color.cgColor
        if textView.text == Layout.Placeholder.text {
            textView.text.removeAll()
        }
        textView.textColor = Layout.textColor
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        didChangeText.send(textView.text)
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.textColor = Layout.textColor

        if textView.text.isEmpty {
            textView.text = Layout.Placeholder.text
            textView.textColor = Layout.Placeholder.color
        }

        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
