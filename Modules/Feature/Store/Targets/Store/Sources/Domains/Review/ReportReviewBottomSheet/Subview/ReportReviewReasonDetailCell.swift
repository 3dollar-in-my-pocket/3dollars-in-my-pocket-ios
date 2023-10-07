import UIKit
import Combine

import Common
import DesignSystem
import Then

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

    private lazy var textView = UITextView().then {
        $0.backgroundColor = Colors.gray10.color
        $0.layer.cornerRadius = 12
        $0.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        $0.text = Layout.Placeholder.text
        $0.textColor = Layout.Placeholder.color
        $0.font = Fonts.regular.font(size: 14)
        $0.keyboardDismissMode = .onDrag
        $0.delegate = self
    }

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
}
