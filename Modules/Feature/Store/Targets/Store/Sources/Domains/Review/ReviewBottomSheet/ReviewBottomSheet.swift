import UIKit

import Common
import DesignSystem

final class ReviewBottomSheet: BaseView {
    enum Constant {
        static let maxLengthOfReview = 300
    }

    enum Layout {
        static let photoSize = CGSize(width: 72, height: 72)
        static let contentHeight: CGFloat = 528
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.semiBold.font(size: 20)
        label.text = Strings.ReviewBottomSheet.title

        return label
    }()

    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.deleteX.image.withTintColor(Colors.gray40.color), for: .normal)

        return button
    }()

    let ratingInputView = RatingInputView()

    let photoListView = ReviewPhotoListView(config: .init(size: Layout.photoSize, canEdit: true))

    let textView: UITextView = {
        let textView = UITextView()
        textView.text = Strings.ReviewBottomSheet.placeholder
        textView.font = Fonts.regular.font(size: 14)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        textView.backgroundColor = Colors.gray0.color
        textView.textColor = Colors.gray40.color
        textView.returnKeyType = .done
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = Colors.gray20.color.cgColor

        return textView
    }()

    private let countLabel = UILabel()

    let writeButton = Button.Normal(size: .h48, text: Strings.ReviewBottomSheet.writeButton)

    override func setup() {
        backgroundColor = Colors.systemWhite.color
        addSubViews([
            titleLabel,
            closeButton,
            ratingInputView,
            photoListView,
            textView,
            countLabel,
            writeButton
        ])

        textView.delegate = self
        updateCount(0)
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(closeButton)
        }

        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
        }

        ratingInputView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(closeButton.snp.bottom).offset(28)
        }

        photoListView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(ratingInputView.snp.bottom).offset(28)
            $0.height.equalTo(Layout.photoSize.height)
        }

        textView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(photoListView.snp.bottom).offset(16)
            $0.height.equalTo(140)
        }

        countLabel.snp.makeConstraints {
            $0.trailing.equalTo(textView)
            $0.top.equalTo(textView.snp.bottom).offset(4)
        }

        writeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(countLabel.snp.bottom).offset(28)
        }
    }

    func setRating(_ rating: Int?) {
        let rating = rating ?? 0
        ratingInputView.onTapStackView(tappedIndex: rating)
    }

    func setContents(_ contents: String?) {
        if let contents, contents.isNotEmpty {
            textView.text = contents
            textView.textColor = Colors.gray70.color
        } else {
            textView.text = Strings.ReviewBottomSheet.placeholder
            textView.textColor = Colors.gray40.color
        }
        updateCount(contents?.count ?? 0)
    }

    private func updateCount(_ count: Int) {
        let text = NSMutableAttributedString(
            string: "\(count)",
            attributes: [
                .font: Fonts.medium.font(size: 12),
                .foregroundColor: count > 0 ? Colors.pink400.color : Colors.gray50.color
            ]
        )
        text.append(NSAttributedString(
            string: "/\(Constant.maxLengthOfReview)",
            attributes: [.font: Fonts.regular.font(size: 12), .foregroundColor: Colors.gray50.color]
        ))
        countLabel.attributedText = text
        textView.layer.borderColor = (count > 0 ? Colors.mainPink.color : Colors.gray20.color).cgColor
    }
}

// MARK: UITextViewDelegate
extension ReviewBottomSheet: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Strings.ReviewBottomSheet.placeholder {
            textView.text = ""
            textView.textColor = Colors.gray70.color
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = Strings.ReviewBottomSheet.placeholder
            textView.textColor = Colors.gray40.color
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        updateCount(textView.text.count)
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        guard let textFieldText = textView.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + text.count

        return count <= Constant.maxLengthOfReview
    }
}
