import UIKit
import Combine

import DesignSystem
import Common

final class PollDetailWriteCommentView: BaseView {
    enum Layout {
        enum Placeholder {
            static let text = "의견 달기"
            static let color = Colors.gray50.color
        }

        static let textColor = Colors.gray100.color
    }

    let didChangeText = PassthroughSubject<String, Never>()

    let lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = Colors.gray30.color
        return lineView
    }()

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = Colors.gray10.color
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.isScrollEnabled = false
        textView.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        textView.text = Layout.Placeholder.text
        textView.textColor = Layout.Placeholder.color
        textView.font = Fonts.regular.font(size: 14)
        textView.keyboardDismissMode = .interactive
        textView.delegate = self
        return textView
    }()

    let writeButton: UIButton = {
        let writeButton = UIButton()
        writeButton.setImage(Icons.writeSolid.image
            .resizeImage(scaledTo: 20)
            .withTintColor(Colors.mainPink.color), for: .normal)
        writeButton.setImage(Icons.writeSolid.image
            .resizeImage(scaledTo: 20)
            .withTintColor(Colors.gray40.color), for: .disabled)
        writeButton.contentEdgeInsets = .init(top: 16, left: 12, bottom: 20, right: 16)
        writeButton.isEnabled = false
        return writeButton
    }()

    override func setup() {
        super.setup()

        backgroundColor = Colors.systemWhite.color

        addSubViews([lineView, textView, writeButton])
    }

    override func bindConstraints() {
        super.bindConstraints()

        lineView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        textView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(48)
        }

        writeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
        }
    }

    func clear() {
        textView.text.removeAll()
        textView.text = Layout.Placeholder.text
        textView.textColor = Layout.Placeholder.color
        writeButton.isEnabled = false
    }
}

extension PollDetailWriteCommentView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.layer.borderColor = Colors.mainPink.color.cgColor
        if textView.textColor == Layout.Placeholder.color {
            textView.text.removeAll()
        }
        textView.textColor = Layout.textColor
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        writeButton.isEnabled = textView.text.isNotEmpty
        didChangeText.send(textView.text)
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.textColor = Layout.textColor

        if textView.text.isEmpty {
            textView.text = Layout.Placeholder.text
            textView.textColor = Layout.Placeholder.color
            writeButton.isEnabled = false
        }

        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.textColor = Layout.textColor

        if textView.text.isEmpty {
            textView.text = Layout.Placeholder.text
            textView.textColor = Layout.Placeholder.color
            writeButton.isEnabled = false
        }
    }
}
