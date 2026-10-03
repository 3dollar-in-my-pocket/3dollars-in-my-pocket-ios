import UIKit
import Combine

import Common
import DesignSystem

import SnapKit

final class GALogViewerViewController: BaseViewController {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = Colors.gray10.color
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.sectionFooterHeight = 0
        return tableView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Fonts.medium.font(size: 14)
        label.textColor = Colors.gray50.color
        label.textAlignment = .center
        return label
    }()

    private var groups: [GALogGroup] = []
    private var expandedRows = Set<IndexPath>()
    private var focusGroupId: UUID?

    init(focusGroupId: UUID? = nil) {
        self.focusGroupId = focusGroupId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        reload()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToFocusGroupIfNeeded()
    }

    private func setupUI() {
        view.backgroundColor = Colors.gray10.color
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "닫기",
            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) }
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "클리어",
            primaryAction: UIAction { _ in GALogStore.shared.clear() }
        )

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GALogEntryCell.self, forCellReuseIdentifier: String(describing: GALogEntryCell.self))
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func bind() {
        GALogStore.shared.didUpdateGroup
            .map { _ in () }
            .merge(with: GALogStore.shared.didClear)
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.reload()
            }
            .store(in: &cancellables)
    }

    private func reload() {
        groups = GALogStore.shared.groups.reversed()
        expandedRows.removeAll()
        title = "GA 로그 (\(GALogStore.shared.entryCount))"
        emptyLabel.text = GALogStore.shared.isRecordingEnabled
            ? "아직 전송된 GA 로그가 없어요"
            : "GA 로그 기록이 꺼져 있어요\n디버깅 메뉴에서 켜주세요"
        emptyLabel.isHidden = groups.isNotEmpty
        tableView.reloadData()
    }

    private func scrollToFocusGroupIfNeeded() {
        guard let focusGroupId, let section = groups.firstIndex(where: { $0.id == focusGroupId }) else { return }
        self.focusGroupId = nil
        tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: false)
    }

    private func presentSnapshot(_ image: UIImage) {
        let viewController = UIViewController()
        viewController.view.backgroundColor = Colors.systemBlack.color
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        viewController.view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalTo(viewController.view.safeAreaLayoutGuide)
        }
        viewController.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSnapshot)))
        present(viewController, animated: true)
    }

    @objc private func dismissSnapshot() {
        presentedViewController?.dismiss(animated: true)
    }
}

extension GALogViewerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[safe: section]?.entries.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: GALogEntryCell.self),
            for: indexPath
        )
        guard let cell = cell as? GALogEntryCell,
              let group = groups[safe: indexPath.section],
              let entry = group.entries[safe: indexPath.row]
        else { return cell }

        cell.bind(
            entry: entry,
            elapsed: entry.date.timeIntervalSince(group.startDate),
            isExpanded: expandedRows.contains(indexPath)
        )
        return cell
    }
}

extension GALogViewerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let group = groups[safe: section] else { return nil }
        let header = GALogGroupHeaderView()
        header.bind(
            time: Self.timeFormatter.string(from: group.startDate),
            group: group
        )
        header.onTapSnapshot = { [weak self] image in
            self?.presentSnapshot(image)
        }
        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if expandedRows.remove(indexPath) == nil {
            expandedRows.insert(indexPath)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

private final class GALogGroupHeaderView: UIView {
    var onTapSnapshot: ((UIImage) -> Void)?

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 13)
        label.textColor = Colors.gray100.color
        return label
    }()

    private let triggerLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray70.color
        label.numberOfLines = 2
        return label
    }()

    private let snapshotButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.gray30.color.cgColor
        return button
    }()

    private var snapshot: UIImage?

    init() {
        super.init(frame: .zero)
        backgroundColor = Colors.gray10.color

        let textStackView = UIStackView(arrangedSubviews: [timeLabel, triggerLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 2

        let contentStackView = UIStackView(arrangedSubviews: [textStackView, snapshotButton])
        contentStackView.axis = .horizontal
        contentStackView.alignment = .top
        contentStackView.spacing = 12
        addSubview(contentStackView)

        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 8, right: 16))
        }
        snapshotButton.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(86)
        }
        snapshotButton.addAction(UIAction { [weak self] _ in
            guard let snapshot = self?.snapshot else { return }
            self?.onTapSnapshot?(snapshot)
        }, for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(time: String, group: GALogGroup) {
        timeLabel.text = "\(time) · \(group.entries.count)건"
        if let tap = group.tap {
            let viewControllerText = tap.viewControllerName.map { " · \($0)" } ?? ""
            triggerLabel.text = "👆 \(tap.elementDescription)\(viewControllerText)"
        } else {
            triggerLabel.text = "트리거 미확인 (노출·화면 진입 또는 비동기 로그)"
        }
        snapshot = group.tap?.snapshot
        snapshotButton.setImage(snapshot, for: .normal)
        snapshotButton.isHidden = snapshot == nil
    }
}

private final class GALogEntryCell: UITableViewCell {
    private let dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 13)
        label.textColor = Colors.gray100.color
        return label
    }()

    private let elapsedLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 11)
        label.textColor = Colors.gray50.color
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 12)
        label.textColor = Colors.gray70.color
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(dotView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(elapsedLabel)
        contentView.addSubview(detailLabel)

        dotView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalTo(nameLabel)
            $0.size.equalTo(8)
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(dotView.snp.trailing).offset(8)
            $0.top.equalToSuperview().offset(10)
            $0.trailing.lessThanOrEqualTo(elapsedLabel.snp.leading).offset(-8)
        }
        elapsedLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(nameLabel)
        }
        detailLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(entry: GALogEntry, elapsed: TimeInterval, isExpanded: Bool) {
        dotView.backgroundColor = entry.kind.color
        nameLabel.text = [entry.name, entry.target].compactMap { $0 }.joined(separator: "  ")
        elapsedLabel.text = String(format: "+%.2fs", elapsed)

        let parameters = isExpanded ? entry.parameters : entry.extraParameters
        let screenText = entry.screen.map { "screen: \($0)" }
        let parameterText = parameters.map { "\($0.key): \($0.value)" }.joined(separator: isExpanded ? "\n" : ", ")
        detailLabel.text = [isExpanded ? nil : screenText, parameterText.isEmpty ? nil : parameterText]
            .compactMap { $0 }
            .joined(separator: isExpanded ? "\n" : " · ")
        detailLabel.numberOfLines = isExpanded ? 0 : 2
    }
}
