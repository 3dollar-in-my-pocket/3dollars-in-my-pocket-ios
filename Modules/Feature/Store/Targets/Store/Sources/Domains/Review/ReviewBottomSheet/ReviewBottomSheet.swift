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
        static let storeNameHeight: CGFloat = 32
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

    private let ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    let storeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.semiBold.font(size: 16)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    let ratingInputView = RatingInputView()

    let photoListView = ReviewPhotoListView(config: .init(size: Layout.photoSize, canEdit: true))

    let textView: UITextView = {
        let textView = UITextView()
        textView.text = Strings.ReviewBottomSheet.placeholder
        textView.font = Fonts.regular.font(size: 14)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = Colors.gray0.color
        textView.textColor = Colors.gray40.color
        textView.returnKeyType = .done
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = Colors.gray20.color.cgColor

        return textView
    }()

    private let lengthGuideLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.ReviewBottomSheet.lengthGuide
        label.textColor = Colors.gray70.color
        label.font = Fonts.regular.font(size: 12)
        return label
    }()

    private let countLabel = UILabel()

    let writeButton = Button.Normal(size: .h48, text: Strings.ReviewBottomSheet.writeButton)

    override func setup() {
        backgroundColor = Colors.systemWhite.color
        addSubViews([
            titleLabel,
            closeButton,
            ratingStackView,
            photoListView,
            textView,
            lengthGuideLabel,
            countLabel,
            writeButton
        ])

        ratingStackView.addArrangedSubview(storeNameLabel)
        ratingStackView.addArrangedSubview(ratingInputView)
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

        ratingStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(closeButton.snp.bottom).offset(28)
        }

        photoListView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(ratingStackView.snp.bottom).offset(28)
            $0.height.equalTo(Layout.photoSize.height)
        }

        textView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(photoListView.snp.bottom).offset(16)
            $0.height.equalTo(140)
        }

        lengthGuideLabel.snp.makeConstraints {
            $0.leading.equalTo(textView)
            $0.top.equalTo(textView.snp.bottom).offset(4)
            $0.trailing.lessThanOrEqualTo(countLabel.snp.leading).offset(-4)
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

    func setStoreName(_ storeName: String?) {
        let storeName = storeName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        storeNameLabel.text = storeName
        storeNameLabel.isHidden = storeName.isEmpty
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
    }
}

// MARK: UITextViewDelegate
extension ReviewBottomSheet: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = Colors.mainPink.color.cgColor
        if textView.text == Strings.ReviewBottomSheet.placeholder {
            textView.text = ""
            textView.textColor = Colors.gray70.color
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = Colors.gray20.color.cgColor
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
