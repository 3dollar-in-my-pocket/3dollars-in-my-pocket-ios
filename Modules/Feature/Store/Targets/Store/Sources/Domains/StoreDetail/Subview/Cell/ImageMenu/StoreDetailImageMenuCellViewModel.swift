import Combine

import Common
import Model

extension StoreDetailImageMenuCellViewModel {
    struct Input {
        let didTapMore = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let menus: CurrentValueSubject<[StoreImageMenusSectionResponse.StoreImageMenuSectionResponse], Never>
        let moreItemCount: CurrentValueSubject<Int, Never>
        let updateHeight = PassthroughSubject<Void, Never>()
    }
    
    struct State {
        let totalMenus: [StoreImageMenusSectionResponse.StoreImageMenuSectionResponse]
    }

    struct Config {
        let data: StoreImageMenusSectionResponse
    }

    enum Constants {
        static let initialViewCount: Int = 5
    }
}

final class StoreDetailImageMenuCellViewModel: BaseViewModel {
    let input = Input()
    let output: Output

    private let state: State

    init(config: Config) {
        self.output = Output(
            menus: .init(Array(config.data.menus.prefix(Constants.initialViewCount))),
            moreItemCount: .init(max(config.data.menus.count - Constants.initialViewCount, 0))
        )
        self.state = State(totalMenus: config.data.menus)

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapMore
            .sink { [weak self] _ in
                self?.showAllMenus()
            }
            .store(in: &cancellables)
    }
    
    private func showAllMenus() {
        output.moreItemCount.send(0)
        output.menus.send(state.totalMenus)
        output.updateHeight.send()
    }
}

extension StoreDetailImageMenuCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension StoreDetailImageMenuCellViewModel: Hashable {
    static func == (lhs: StoreDetailImageMenuCellViewModel, rhs: StoreDetailImageMenuCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
