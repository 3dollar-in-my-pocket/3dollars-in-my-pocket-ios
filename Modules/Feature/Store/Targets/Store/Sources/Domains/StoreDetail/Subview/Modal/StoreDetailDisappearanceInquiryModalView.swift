//
//  StoreDetailDisappearanceInquiryModalView.swift
//  Store
//
//  Created by Hakyung Kim on 11/22/25.
//  Copyright © 2025 macgongmon. All rights reserved.
//

import UIKit
import SnapKit
import Common
import DesignSystem

final class StoreDetailDisappearanceInquiryModalView: BaseView {

    private let containerView = UIView().then {
        $0.backgroundColor = Colors.mainRed.color
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = .white
        $0.numberOfLines = 1
    }

    private let subtitleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = UIColor.white.withAlphaComponent(0.6)
        $0.numberOfLines = 1
    }

    private let reportButton = UIButton().then {
        $0.backgroundColor = .white
        $0.setTitleColor(Colors.mainRed.color, for: .normal)
        $0.titleLabel?.font = Fonts.bold.font(size: 12)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }

    private lazy var stackView = UIStackView(arrangedSubviews: [
        titleLabel,
        subtitleLabel
    ]).then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
    }

    // MARK: - ViewModel

    private var viewModel: StoreDetailDisappearanceInquiryModalViewModel?

    // MARK: - Setup

    override func setup() {
        super.setup()
        backgroundColor = .clear

        addSubview(containerView)
        containerView.addSubViews([
            stackView,
            reportButton
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(14)
            $0.trailing.lessThanOrEqualTo(reportButton.snp.leading).offset(-4)
        }

        reportButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(34)
            $0.width.equalTo(62)
        }
    }

    // MARK: - Binding

    func bind(viewModel: StoreDetailDisappearanceInquiryModalViewModel) {
        self.viewModel = viewModel
        cancellables.removeAll()

        titleLabel.text = viewModel.output.title
        subtitleLabel.text = viewModel.output.subtitle
        reportButton.setTitle(viewModel.output.reportButtonTitle, for: .normal)
        
        reportButton.tapPublisher
            .subscribe(viewModel.input.didTapReport)
            .store(in: &cancellables)
    }
}
