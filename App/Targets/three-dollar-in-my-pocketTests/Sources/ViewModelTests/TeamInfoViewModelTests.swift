import Combine
import XCTest

import Model
@testable import MyPage

final class TeamInfoViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1545 TC1, TC2

    func test_TH1545_TC1_팀원소개화면에진입하면_서버의역할별팀원목록이순서대로전달된다() throws {
        // Given
        let repository = MockServiceCreatorRepository()
        let response = try FixtureLoader.decode(ContentListCreatorGroupResponse.self, from: "ServiceCreators")
        repository.listCreatorsResult = .success(response)
        let viewModel = TeamInfoViewModel(dependency: .init(serviceCreatorRepository: repository))
        let received = expectation(description: "creator groups")
        var creatorGroups: [CreatorGroupResponse] = []
        viewModel.output.creatorGroups.sink {
            creatorGroups = $0
            received.fulfill()
        }.store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        wait(for: [received], timeout: 1)
        XCTAssertEqual(creatorGroups, response.contents)
        XCTAssertEqual(creatorGroups.first?.role, "iOS")
    }

    func test_TH1545_TC2_팀원이없는역할은_목록에서제외된다() {
        // Given
        let repository = MockServiceCreatorRepository()
        repository.listCreatorsResult = .success(ContentListCreatorGroupResponse(contents: [
            CreatorGroupResponse(role: "iOS", creatorNames: ["유현식"]),
            CreatorGroupResponse(role: "Marketer", creatorNames: [])
        ]))
        let viewModel = TeamInfoViewModel(dependency: .init(serviceCreatorRepository: repository))
        let received = expectation(description: "creator groups")
        var creatorGroups: [CreatorGroupResponse] = []
        viewModel.output.creatorGroups.sink {
            creatorGroups = $0
            received.fulfill()
        }.store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        wait(for: [received], timeout: 1)
        XCTAssertEqual(creatorGroups.map(\.role), ["iOS"])
    }

    // MARK: TH-1545 TC3

    func test_TH1545_TC3_팀원목록조회가실패하면_에러알럿route가발행된다() {
        // Given
        let viewModel = TeamInfoViewModel(dependency: .init(serviceCreatorRepository: MockServiceCreatorRepository()))
        let errorShown = expectation(description: "error alert")
        viewModel.output.route.sink { route in
            if case .showErrorAlert = route { errorShown.fulfill() }
        }.store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        wait(for: [errorShown], timeout: 1)
    }
}
