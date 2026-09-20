import UIKit
import Combine

import Common
import DesignSystem

final class ReportPollReasonDetailCell: BaseCollectionViewCell {

    let didChangeText = PassthroughSubject<String, Never>()

    enum Layout {
        static let height: CGFloat = 80

        enum Placeholder {
            static let text = "신고 사유 직접 입력"
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

    func bind() {

    }
}

extension ReportPollReasonDetailCell: UITextViewDelegate {
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
}
