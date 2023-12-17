import Combine

import Common
import Model

final class BossStoreMenuListCellViewModel: BaseViewModel {
    struct Input {
        let didTapMore = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let menuList: CurrentValueSubject<[BossStoreMenu], Never>
        let moreItemCount: CurrentValueSubject<Int, Never>
        let updateHeight = PassthroughSubject<Void, Never>()
    }

    struct State {
        let menus: [BossStoreMenu]
    }

    enum Constants {
        static let initialViewCount: Int = 5
    }

    let input = Input()
    let output: Output

    private let state: State

    init(menus: [BossStoreMenu]) {
        self.output = Output(
            menuList: .init(Array(menus.prefix(Constants.initialViewCount))),
            moreItemCount: .init(max(menus.count - Constants.initialViewCount, 0))
        )
        self.state = State(menus: menus)

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapMore
            .withUnretained(self)
            .sink { owner, _ in
                owner.output.moreItemCount.send(0)
                owner.output.menuList.send(owner.state.menus)
                owner.output.updateHeight.send()
            }
            .store(in: &cancellables)
    }
}

extension BossStoreMenuListCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStoreMenuListCellViewModel: Hashable {
    static func == (lhs: BossStoreMenuListCellViewModel, rhs: BossStoreMenuListCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
