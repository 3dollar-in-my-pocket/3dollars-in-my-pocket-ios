import Combine
import XCTest

import Model
@testable import Home

final class HomeListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    private func makeViewModel() -> HomeListViewModel {
        return HomeListViewModel(dependency: .init(logManager: MockLogManager()))
    }

    // MARK: TH-1364 TC1, TH-1358 TC1 — 새 조회 결과로 교체되면 리스트 초기화

    func test_TH1364_TC1_카드목록이교체되면_리스트초기화를한번요청한다() {
        // Given
        let viewModel = makeViewModel()
        var resetCount = 0
        viewModel.output.resetList
            .sink { resetCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.updateCards.send([])
        viewModel.input.didReplaceCards.send(())

        // Then
        XCTAssertEqual(resetCount, 1)
    }

    func test_TH1364_TC2_페이지네이션으로카드가추가되기만하면_리스트초기화를요청하지않는다() {
        // Given
        let viewModel = makeViewModel()
        var resetCount = 0
        viewModel.output.resetList
            .sink { resetCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.updateCards.send([])
        viewModel.input.updateCards.send([])

        // Then
        XCTAssertEqual(resetCount, 0)
    }
}
