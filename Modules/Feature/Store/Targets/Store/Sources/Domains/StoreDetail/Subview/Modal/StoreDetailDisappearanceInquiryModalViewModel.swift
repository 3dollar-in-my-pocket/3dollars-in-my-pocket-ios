//
//  StoreDetailDisappearanceInquiryModalViewModel.swift
//  Store
//
//  Created by Hakyung Kim on 11/22/25.
//  Copyright © 2025 macgongmon. All rights reserved.
//

import UIKit
import Combine
import Common
import DesignSystem
import Model

final class StoreDetailDisappearanceInquiryModalViewModel: BaseViewModel {
    struct Input {
        let didTapReport = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let title: String
        let subtitle: String
        let reportButtonTitle: String

        let moveToReport = PassthroughSubject<Void, Never>()
    }

    let input = Input()
    let output: Output

    override init() {
        self.output = Output(
            title: "혹시 가게가 사라졌나요?",
            subtitle: "오랫동안 보이지 않는 가게라면 신고해주세요.",
            reportButtonTitle: "신고하기"
        )
        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapReport
            .sink { [weak self] _ in
                self?.output.moveToReport.send(())
            }
            .store(in: &cancellables)
    }
}
