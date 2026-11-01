import UIKit

import Common
import DesignSystem

final class TeamMemberView: BaseView {
    enum Layout {
        static let width: CGFloat = 136
        static let horizontalInset: CGFloat = 20
        static let membersPerRow = 2
    }

    private let containerView: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 12
        view.backgroundColor = Colors.pink500.color
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()

        label.textColor = Colors.pink200.color
        label.font = Fonts.medium.font(size: 10)
        label.textAlignment = .center
        return label
    }()

    private let memberStackView: UIStackView = {
        let stackView = UIStackView()

        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    init(teamName: String, members: [String]) {
        super.init(frame: .zero)

        bind(teamName: teamName, members: members)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        addSubViews([
            containerView,
            titleLabel,
            memberStackView
        ])
    }

    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.top.equalToSuperview().offset(12)
        }

        memberStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-16)
        }

        snp.makeConstraints {
            $0.width.equalTo(Layout.width)
        }
    }

    private func bind(teamName: String, members: [String]) {
        titleLabel.text = teamName

        stride(from: 0, to: members.count, by: Layout.membersPerRow)
            .map { Array(members[$0..<min($0 + Layout.membersPerRow, members.count)]) }
            .forEach { memberStackView.addArrangedSubview(makeRowView(members: $0)) }
    }

    private func makeRowView(members: [String]) -> UIView {
        let rowView = UIView()
        let labels = members.map(makeMemberLabel)
        rowView.addSubViews(labels)

        if let leadingLabel = labels.first, labels.count == 1 {
            leadingLabel.snp.makeConstraints {
                $0.centerX.top.bottom.equalToSuperview()
            }
        } else if let leadingLabel = labels.first, let trailingLabel = labels.last {
            leadingLabel.snp.makeConstraints {
                $0.leading.top.bottom.equalToSuperview()
            }

            trailingLabel.snp.makeConstraints {
                $0.trailing.equalToSuperview()
                $0.leading.greaterThanOrEqualTo(leadingLabel.snp.trailing).offset(8)
                $0.centerY.equalTo(leadingLabel)
            }
        }
        return rowView
    }

    private func makeMemberLabel(name: String) -> UILabel {
        let label = UILabel()

        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.systemWhite.color
        label.text = name
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }
}
