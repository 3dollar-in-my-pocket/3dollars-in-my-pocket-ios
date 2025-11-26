//
//  StoreDetailBossStoreAppIntroCellViewModel.swift
//  Store
//
//  Created by Hakyung Kim on 11/23/25.
//  Copyright © 2025 macgongmon. All rights reserved.
//

import UIKit
import Combine
import Common
import DesignSystem

final class StoreDetailBossStoreAppIntroCellViewModel: BaseViewModel {

    struct Input {
        let didTapIntro = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let title: String
        let subtitle: String
        let introTitle: String

        let moveToBossAppIntro = PassthroughSubject<Void, Never>()
    }

    let input = Input()
    let output: Output
    
    lazy var identifier = ObjectIdentifier(self)

    override init() {
        self.output = Output(
            title: "🧑‍🍳 혹시 이 가게 사장님이신가요?",
            subtitle: "가슴속 3천원 사장님앱으로 가게 정보를 직접 관리할 수 있습니다!",
            introTitle: "사장님 앱 소개보기"
        )

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapIntro
            .subscribe(output.moveToBossAppIntro)
            .store(in: &cancellables)
    }
}

extension StoreDetailBossStoreAppIntroCellViewModel: Hashable {
    static func == (lhs: StoreDetailBossStoreAppIntroCellViewModel, rhs: StoreDetailBossStoreAppIntroCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
