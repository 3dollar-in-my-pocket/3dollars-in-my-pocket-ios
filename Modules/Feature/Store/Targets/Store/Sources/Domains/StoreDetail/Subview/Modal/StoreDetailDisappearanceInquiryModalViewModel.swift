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
import Networking
import Log

final class StoreDetailDisappearanceInquiryModalViewModel: BaseViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let didTapReason = PassthroughSubject<Int, Never>()
        let didTapReport = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let title: String
        let subtitle: String
        let reportButtonTitle: String

        let reasons = CurrentValueSubject<[ReportReason], Never>([])
        let selectedIndex = CurrentValueSubject<Int?, Never>(nil)
        let isReportEnabled = CurrentValueSubject<Bool, Never>(false)
        let onReportSucceed = PassthroughSubject<Void, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct Config {
        let storeId: Int
    }

    struct State {
        var selectedReason: ReportReason?
    }

    struct Dependency {
        let reportRepository: ReportRepository
        let storeRepository: StoreRepository

        init(
            reportRepository: ReportRepository = ReportRepositoryImpl(),
            storeRepository: StoreRepository = StoreRepositoryImpl()
        ) {
            self.reportRepository = reportRepository
            self.storeRepository = storeRepository
        }
    }

    let input = Input()
    let output: Output
    private let config: Config
    private var state = State()
    private let dependency: Dependency

    init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
        self.dependency = dependency
        self.output = Output(
            title: Strings.DisappearanceInquiryModal.title,
            subtitle: Strings.ReportModal.description,
            reportButtonTitle: Strings.ReportModal.button
        )
        super.init()
    }

    override func bind() {
        super.bind()

        input.load
            .first()
            .sink { [weak self] in
                self?.fetchReasons()
            }
            .store(in: &cancellables)

        input.didTapReason
            .withUnretained(self)
            .sink { (owner, index) in
                guard let reason = owner.output.reasons.value[safe: index] else { return }
                owner.state.selectedReason = reason
                owner.output.selectedIndex.send(index)
                owner.output.isReportEnabled.send(true)
            }
            .store(in: &cancellables)

        input.didTapReport
            .withUnretained(self)
            .sink { (owner, _) in
                owner.reportStore()
            }
            .store(in: &cancellables)
    }

    private func fetchReasons() {
        Task { [weak self] in
            guard let self else { return }
            let result = await dependency.reportRepository.fetchReportReasons(group: .store)
                .map { response in response.reasons.map { ReportReason(response: $0) } }

            switch result {
            case .success(let reasons):
                output.reasons.send(reasons)
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }

    private func reportStore() {
        guard let reason = state.selectedReason else { return }
        Task { [weak self] in
            guard let self else { return }
            let result = await dependency.storeRepository.reportStore(
                storeId: config.storeId,
                reportReason: reason.type
            )

            switch result {
            case .success:
                output.onReportSucceed.send(())
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}
