//
//  StoreDetailDisappearanceInquiryModalView.swift
//  Store
//
//  Created by Hakyung Kim on 11/22/25.
//  Copyright © 2025 macgongmon. All rights reserved.
//

import UIKit
import Combine

import SnapKit
import Common
import DesignSystem
import Model

final class StoreDetailDisappearanceInquiryModalView: BaseView, DismissibleStoreDetailModal {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.layer.borderColor = Colors.gray20.color.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray50.color
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let reasonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()

    private let reportButton: Button.Normal = {
        let button = Button.Normal(size: .h48, text: Strings.ReportModal.button)
        button.enabledBackgroundColor = Colors.mainRed.color
        button.isEnabled = false
        return button
    }()

    private var viewModel: StoreDetailDisappearanceInquiryModalViewModel?
    private var reasonRowMap: [Int: DisappearanceReasonRow] = [:]

    override func setup() {
        super.setup()
        backgroundColor = .clear

        addSubview(containerView)
        containerView.addSubViews([
            titleLabel,
            subtitleLabel,
            reasonsStackView,
            reportButton
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        reasonsStackView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        reportButton.snp.makeConstraints {
            $0.top.equalTo(reasonsStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
    }

    func bind(viewModel: StoreDetailDisappearanceInquiryModalViewModel) {
        self.viewModel = viewModel
        cancellables.removeAll()

        titleLabel.text = viewModel.output.title
        subtitleLabel.attributedText = makeHighlightedSubtitle(viewModel.output.subtitle, keyword: Strings.ReportModal.descriptionBold)

        viewModel.output.reasons
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner, reasons) in
                owner.renderReasons(reasons)
            }
            .store(in: &cancellables)

        viewModel.output.selectedIndex
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner, selectedIndex) in
                owner.updateSelection(selectedIndex)
            }
            .store(in: &cancellables)

        viewModel.output.isReportEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: reportButton)
            .store(in: &cancellables)

        reportButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapReport)
            .store(in: &cancellables)

        viewModel.input.load.send(())
    }

    private func renderReasons(_ reasons: [ReportReason]) {
        reasonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        reasonRowMap.removeAll()

        for (index, reason) in reasons.enumerated() {
            let row = DisappearanceReasonRow()
            row.bind(reason: reason)
            row.controlPublisher(for: .touchUpInside)
                .map { _ in index }
                .sink { [weak self] tappedIndex in
                    self?.viewModel?.input.didTapReason.send(tappedIndex)
                }
                .store(in: &cancellables)
            reasonRowMap[index] = row
            reasonsStackView.addArrangedSubview(row)
            row.snp.makeConstraints {
                $0.height.equalTo(44)
            }
        }
    }

    private func updateSelection(_ selectedIndex: Int?) {
        for (index, row) in reasonRowMap {
            row.setSelected(index == selectedIndex)
        }
    }

    private func makeHighlightedSubtitle(_ text: String, keyword: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: Fonts.medium.font(size: 12) as Any,
                .foregroundColor: Colors.gray60.color as Any
            ]
        )
        let range = (text as NSString).range(of: keyword)
        if range.location != NSNotFound {
            attributed.addAttribute(.foregroundColor, value: Colors.gray80.color as Any, range: range)
        }
        return attributed
    }
}

final class DisappearanceReasonRow: UIControl {
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderColor = Colors.gray40.color.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = Colors.systemWhite.color
        view.isUserInteractionEnabled = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray60.color
        label.isUserInteractionEnabled = false
        return label
    }()

    private let checkImageView: UIImageView = {
        let imageView = UIImageView(image: Icons.check.image.withTintColor(Colors.mainRed.color))
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(reason: ReportReason) {
        titleLabel.text = reason.description
    }

    func setSelected(_ selected: Bool) {
        if selected {
            containerView.layer.borderColor = Colors.mainRed.color.cgColor
            checkImageView.isHidden = false
            titleLabel.textColor = Colors.gray100.color
        } else {
            containerView.layer.borderColor = Colors.gray40.color.cgColor
            checkImageView.isHidden = true
            titleLabel.textColor = Colors.gray80.color
        }
    }

    private func setup() {
        addSubview(containerView)
        addSubview(titleLabel)
        addSubview(checkImageView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }

        checkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
    }
}
