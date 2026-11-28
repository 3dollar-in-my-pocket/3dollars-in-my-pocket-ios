import XCTest

import Model
@testable import dollar_in_my_pocket

final class BottomNavigationLoaderTests: XCTestCase {

    // MARK: TH-1649 TC7

    func test_TH1649_TC7_응답이오면_저장소에_저장된다() async throws {
        // Given
        let repository = MockScreenRepository()
        let response = try FixtureLoader.decode(BottomNavigationResponse.self, from: "BottomNavigation")
        repository.getBottomNavigationResult = .success(response)
        let store = BottomNavigationStore()
        let loader = BottomNavigationLoader(repository: repository, store: store)

        // When
        loader.load()
        await loader.waitUntilLoaded(timeout: 5)

        // Then
        XCTAssertEqual(store.response, response)
    }

    func test_TH1649_TC7_실패하면_저장소가_비어_기본탭으로_진입한다() async {
        // Given
        let repository = MockScreenRepository()
        let store = BottomNavigationStore()
        let loader = BottomNavigationLoader(repository: repository, store: store)

        // When
        loader.load()
        await loader.waitUntilLoaded(timeout: 5)

        // Then
        XCTAssertNil(store.response)
        XCTAssertEqual(MainTabBarItem.items(from: store.response), MainTabBarItem.all)
    }

    func test_TH1649_TC7_응답이_타임아웃보다_늦으면_기다리지않고_돌아온다() async throws {
        // Given
        let repository = MockScreenRepository()
        let response = try FixtureLoader.decode(BottomNavigationResponse.self, from: "BottomNavigation")
        repository.getBottomNavigationHandler = {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            return .success(response)
        }
        let store = BottomNavigationStore()
        let loader = BottomNavigationLoader(repository: repository, store: store)
        let start = Date()

        // When
        loader.load()
        await loader.waitUntilLoaded(timeout: 0.2)

        // Then
        XCTAssertLessThan(Date().timeIntervalSince(start), 2)
        XCTAssertNil(store.response)
    }

    func test_TH1649_TC7_불러오기전이면_기다리지않는다() async {
        // Given
        let loader = BottomNavigationLoader(repository: MockScreenRepository(), store: BottomNavigationStore())
        let start = Date()

        // When
        await loader.waitUntilLoaded(timeout: 5)

        // Then
        XCTAssertLessThan(Date().timeIntervalSince(start), 1)
    }
}
