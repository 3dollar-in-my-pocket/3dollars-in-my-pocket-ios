import Foundation

import Model
import Networking

/// ScreenRepository 목. 필요한 메서드만 `xxxResult`로 스텁하고, 나머지는 `.failure(MockError.notStubbed)`를 돌려준다.
final class MockScreenRepository: ScreenRepository {
    var fetchHomeFilterScreenResult: Result<HomeFilterScreenResponse, Error> = .failure(MockError.notStubbed())
    var fetchHomeSectionListResult: Result<HomeListSectionResponse, Error> = .failure(MockError.notStubbed())
    private(set) var fetchHomeSectionListInputs: [FetchHomeSectionListInput] = []

    init(
        fetchHomeFilterScreenResult: Result<HomeFilterScreenResponse, Error>? = nil,
        fetchHomeSectionListResult: Result<HomeListSectionResponse, Error>? = nil
    ) {
        if let fetchHomeFilterScreenResult {
            self.fetchHomeFilterScreenResult = fetchHomeFilterScreenResult
        }
        if let fetchHomeSectionListResult {
            self.fetchHomeSectionListResult = fetchHomeSectionListResult
        }
    }

    func fetchHomeFilterScreen(input: FetchHomeFilterScreenInput) async -> Result<HomeFilterScreenResponse, Error> {
        fetchHomeFilterScreenResult
    }

    func fetchHomeSectionList(input: FetchHomeSectionListInput) async -> Result<HomeListSectionResponse, Error> {
        fetchHomeSectionListInputs.append(input)
        return fetchHomeSectionListResult
    }
}
