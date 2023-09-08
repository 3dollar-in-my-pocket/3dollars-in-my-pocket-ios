import UIKit
import Combine

import DesignSystem

final class CommunityTabView: UIView {

    enum Layout {
        static let height: CGFloat = 40
        static let lineHeight: CGFloat = 2
    }

    let didTap = PassthroughSubject<Int, Never>()

    private lazy var tabButtonStackView = UIStackView()
    private lazy var tabButtonUnderlinedView = UIView()

    private var tabButtons: [UIButton] = [] {
        didSet {
            tabButtons.forEach { tabButtonStackView.addArrangedSubview($0) }
        }
    }

    init(titles: [String], initialSelectedIndex: Int = 0) {
        super.init(frame: .zero)

        setupUI()

        for (index, title) in titles.enumerated() {
            createTabButton(title: title, index: index)
        }

        for tabButton in tabButtons where tabButton.tag == initialSelectedIndex {
            tabButton.isSelected = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }

        addSubview(tabButtonStackView)
        addSubview(tabButtonUnderlinedView)

        tabButtonUnderlinedView.backgroundColor = Colors.mainPink.color

        tabButtonStackView.axis = .horizontal
        tabButtonStackView.spacing = 16
        tabButtonStackView.distribution = .fillEqually

        tabButtonStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func createTabButton(title: String, index: Int) {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Fonts.Pretendard.semiBold.font(size: 14)
        button.setTitleColor(Colors.mainPink.color, for: .selected)
        button.setTitleColor(Colors.gray30.color, for: .normal)
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        button.tag = index
        tabButtons.append(button)

        if index == 0 {
            tabButtonUnderlinedView.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.width.equalTo(button.snp.width)
                $0.height.equalTo(Layout.lineHeight)
            }
        }
    }

    @objc private func didTapButton(_ sender: UIButton) {
        let tabIndex = sender.tag

        didTap.send(tabIndex)
        updateSelect(tabIndex)
    }

    private func transformUnderlinedView(index: Int) {
        guard let targetButton = tabButtons[safe: index] else { return }

        let transform = CGAffineTransform.identity
            .translatedBy(x: targetButton.frame.minX, y: 0)

        tabButtonUnderlinedView.snp.remakeConstraints {
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(targetButton.snp.width)
            $0.height.equalTo(Layout.lineHeight)
        }

        UIView.animate(withDuration: 0.2) {
            self.tabButtonUnderlinedView.transform = transform
        }
    }

    func updateTitle(title: String, index: Int) {
        tabButtons.first { $0.tag == index }?.setTitle(title, for: .normal)
    }

    func initialUnderlinedView() {
        tabButtons.forEach {
            $0.isSelected = ($0.tag == 0)
        }

        transformUnderlinedView(index: 0)
    }

    func updateSelect(_ index: Int) {
        tabButtons.forEach {
            $0.isSelected = (index == $0.tag)
        }

        transformUnderlinedView(index: index)
    }
}
