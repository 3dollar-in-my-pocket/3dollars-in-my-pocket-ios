import UIKit
import Combine

import Common
import DesignSystem
import Model

import Kingfisher
import SnapKit

final class HomeMapControlView: BaseView {
    enum Layout {
        static let buttonSize: CGFloat = 48
        /// 서버 이미지는 28pt, 폴백 아이콘은 24pt 라 버튼 48pt 를 맞추기 위한 inset 이 다르다.
        static let serverImageInset: CGFloat = 10
        static let fallbackIconInset: CGFloat = 12
        static let spacing: CGFloat = 8
    }

    let didTapButton = PassthroughSubject<Int, Never>()
    private var renderedButtons: [HomeMapControlButton] = []

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.spacing
        stackView.alignment = .leading
        return stackView
    }()

    override func setup() {
        addSubViews([stackView])
    }

    override func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func bind(buttons: [HomeMapControlButton]) {
        guard buttons != renderedButtons else { return }
        renderedButtons = buttons

        let existingButtons = stackView.arrangedSubviews.compactMap { $0 as? UIButton }
        if existingButtons.count == buttons.count {
            for (button, item) in zip(existingButtons, buttons) {
                configure(button, with: item)
            }
            return
        }

        existingButtons.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for (index, item) in buttons.enumerated() {
            let button = makeButton()
            button.tag = index
            configure(button, with: item)
            stackView.addArrangedSubview(button)
            button.snp.makeConstraints {
                $0.size.equalTo(Layout.buttonSize)
            }
        }
    }

    private func makeButton() -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = Layout.buttonSize / 2
        button.layer.shadowColor = Colors.systemBlack.color.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 1
        button.layer.shadowOpacity = 0.1
        button.addTarget(self, action: #selector(didTapControlButton(_:)), for: .touchUpInside)
        return button
    }

    private func configure(_ button: UIButton, with item: HomeMapControlButton) {
        switch item {
        case .serverDriven(let sdButton):
            button.contentEdgeInsets = uniformInsets(Layout.serverImageInset)
            button.setSDButton(sdButton)
            button.imageEdgeInsets = .zero
            button.titleEdgeInsets = .zero
            button.imageView?.alpha = (sdButton.image?.style.dimmed ?? false) ? 0.5 : 1
        case .fallbackCurrentLocation:
            button.contentEdgeInsets = uniformInsets(Layout.fallbackIconInset)
            button.kf.cancelImageDownloadTask()
            button.setImage(Icons.locationCurrent.image.withTintColor(Colors.systemBlack.color), for: .normal)
            button.imageView?.alpha = 1
            button.backgroundColor = Colors.systemWhite.color
            button.layer.borderWidth = 1
            button.layer.borderColor = Colors.gray20.color.cgColor
        }
    }

    private func uniformInsets(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }

    @objc private func didTapControlButton(_ sender: UIButton) {
        didTapButton.send(sender.tag)
    }
}
