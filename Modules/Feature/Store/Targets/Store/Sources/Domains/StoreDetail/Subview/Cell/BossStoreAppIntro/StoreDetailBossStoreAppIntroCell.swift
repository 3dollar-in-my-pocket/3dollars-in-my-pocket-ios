//
//  StoreDetailBossStoreAppIntroCell.swift
//  Store
//
//  Created by Hakyung Kim on 11/23/25.
//  Copyright © 2025 macgongmon. All rights reserved.
//

import UIKit
import SnapKit
import Common
import DesignSystem

final class StoreDetailBossStoreAppIntroCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 89
    }

    // MARK: - UI

    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray70.color
        $0.numberOfLines = 1
    }

    private let subtitleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray50.color
        $0.numberOfLines = 1
    }

    private let introButton = UIButton().then {
        $0.titleLabel?.font = Fonts.medium.font(size: 12)
        $0.semanticContentAttribute = .forceRightToLeft
        $0.setTitleColor(Colors.mainGreen.color, for: .normal)
        $0.setImage(Icons.arrowRight.image
            .resizeImage(scaledTo: 12)
            .withTintColor(Colors.mainGreen.color), for: .normal)
    }

    private let containerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
    }

    private lazy var textStack = UIStackView(arrangedSubviews: [
        titleLabel, subtitleLabel
    ]).then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.distribution = .fill
        $0.alignment = .leading
    }


    // MARK: - Setup

    override func setup() {
        super.setup()

        backgroundColor = .white
        contentView.addSubview(containerView)

        containerView.addSubViews([
            textStack,
            introButton
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        textStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(12)
        }

        introButton.snp.makeConstraints {
            $0.top.equalTo(textStack.snp.bottom).offset(9)
            $0.leading.equalToSuperview().inset(20)
        }
    }

    // MARK: - Bind

    func bind(viewModel: StoreDetailBossStoreAppIntroCellViewModel) {
        cancellables.removeAll()

        titleLabel.text = viewModel.output.title
        subtitleLabel.text = viewModel.output.subtitle
        introButton.setTitle(viewModel.output.introTitle, for: .normal)

        introButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapIntro)
            .store(in: &cancellables)
    }
}
