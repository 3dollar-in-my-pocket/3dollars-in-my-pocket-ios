import UIKit
import Combine

import Common
import DesignSystem

import SnapKit

final class GALogToastContainerView: UIView {
    private enum Layout {
        static let maximumCardCount = 2
        static let displayDuration: TimeInterval = 2.5
        static let topInset: CGFloat = 4
        static let horizontalInset: CGFloat = 12
    }

    var onTapGroup: ((UUID) -> Void)?

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
    }()

    private var cards: [UUID: GALogToastCardView] = [:]
    private var dismissWorkItems: [UUID: DispatchWorkItem] = [:]
    private var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(Layout.topInset)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView === self || hitView === stackView ? nil : hitView
    }

    private func bind() {
        GALogStore.shared.didUpdateGroup
            .receive(on: DispatchQueue.main)
            .sink { [weak self] group in
                self?.show(group)
            }
            .store(in: &cancellables)

        GALogStore.shared.didClear
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.removeAllCards()
            }
            .store(in: &cancellables)
    }

    private func show(_ group: GALogGroup) {
        let store = GALogStore.shared
        guard store.isRecordingEnabled, store.isToastEnabled else { return }
        let lines = group.collapsedLines(includesImpression: store.isImpressionToastEnabled)
        guard lines.isNotEmpty else { return }

        let card: GALogToastCardView
        if let existingCard = cards[group.id] {
            card = existingCard
        } else {
            card = makeCard(groupId: group.id)
            cards[group.id] = card
            stackView.insertArrangedSubview(card, at: 0)
            removeOverflowCards()
        }
        card.bind(group: group, lines: lines)
        scheduleDismiss(groupId: group.id)
    }

    private func makeCard(groupId: UUID) -> GALogToastCardView {
        let card = GALogToastCardView()
        card.onTap = { [weak self] in
            self?.removeCard(groupId: groupId)
            self?.onTapGroup?(groupId)
        }
        card.onHoldChanged = { [weak self] isHolding in
            if isHolding {
                self?.dismissWorkItems[groupId]?.cancel()
            } else {
                self?.scheduleDismiss(groupId: groupId)
            }
        }
        return card
    }

    private func scheduleDismiss(groupId: UUID) {
        dismissWorkItems[groupId]?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.removeCard(groupId: groupId)
        }
        dismissWorkItems[groupId] = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Layout.displayDuration, execute: workItem)
    }

    private func removeOverflowCards() {
        let overflowCards = stackView.arrangedSubviews.dropFirst(Layout.maximumCardCount)
        for case let card as GALogToastCardView in overflowCards {
            if let groupId = cards.first(where: { $0.value === card })?.key {
                removeCard(groupId: groupId)
            }
        }
    }

    private func removeCard(groupId: UUID) {
        dismissWorkItems[groupId]?.cancel()
        dismissWorkItems[groupId] = nil
        guard let card = cards.removeValue(forKey: groupId) else { return }
        UIView.animate(withDuration: 0.2, animations: {
            card.alpha = 0
        }, completion: { _ in
            card.removeFromSuperview()
        })
    }

    private func removeAllCards() {
        Array(cards.keys).forEach(removeCard(groupId:))
    }
}

final class GALogToastCardView: UIView {
    private enum Layout {
        static let maximumLineCount = 3
    }

    var onTap: (() -> Void)?
    var onHoldChanged: ((Bool) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 12)
        label.textColor = Colors.systemWhite.color
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let linesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = Colors.gray100.color.withAlphaComponent(0.88)
        layer.cornerRadius = 12
        layer.masksToBounds = true

        let stackView = UIStackView(arrangedSubviews: [titleLabel, linesStackView])
        stackView.axis = .vertical
        stackView.spacing = 4
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        longPress.minimumPressDuration = 0.3
        addGestureRecognizer(longPress)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(group: GALogGroup, lines: [(entry: GALogEntry, count: Int)]) {
        let tapText = group.tap.map { "👆 \($0.elementDescription)" } ?? "📡 로그"
        titleLabel.text = "\(tapText) · 로그 \(group.entries.count)건"

        linesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for line in lines.prefix(Layout.maximumLineCount) {
            linesStackView.addArrangedSubview(makeLineLabel(entry: line.entry, count: line.count))
        }
        let hiddenCount = lines.dropFirst(Layout.maximumLineCount).reduce(0) { $0 + $1.count }
        if hiddenCount > 0 {
            linesStackView.addArrangedSubview(makeTextLabel("+\(hiddenCount)건 더", color: Colors.gray40.color))
        }
    }

    private func makeLineLabel(entry: GALogEntry, count: Int) -> UILabel {
        let text = NSMutableAttributedString(string: "● ", attributes: [.foregroundColor: entry.kind.color])
        var body = entry.name
        if let target = entry.target {
            body += "  \(target)"
        } else if entry.kind == .pageView, let screen = entry.screen {
            body += "  \(screen)"
        }
        if let parameter = entry.extraParameters.first(where: { $0.key == "store_id" }) ?? entry.extraParameters.first {
            body += "  \(parameter.key)=\(parameter.value)"
        }
        if count > 1 {
            body += "  ×\(count)"
        }
        let bodyColor = entry.kind == .impression ? Colors.gray40.color : Colors.systemWhite.color
        text.append(NSAttributedString(string: body, attributes: [.foregroundColor: bodyColor]))

        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.attributedText = text
        label.lineBreakMode = .byTruncatingTail
        return label
    }

    private func makeTextLabel(_ text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 11)
        label.textColor = color
        label.text = text
        return label
    }

    @objc private func didTap() {
        onTap?()
    }

    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            onHoldChanged?(true)
        case .ended, .cancelled, .failed:
            onHoldChanged?(false)
        default:
            break
        }
    }
}
