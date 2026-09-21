import XCTest

import Common

final class StoreIdDebugPreferenceTests: XCTestCase {
    private var suiteName: String!
    private var preference: Preference!

    override func setUp() {
        super.setUp()
        suiteName = "StoreIdDebugPreferenceTests-\(UUID().uuidString)"
        preference = Preference(name: suiteName)
    }

    override func tearDown() {
        UserDefaults().removePersistentDomain(forName: suiteName)
        preference = nil
        suiteName = nil
        super.tearDown()
    }

    // MARK: TC1

    func test_TC1_한번도켠적없으면_기본값은꺼짐이다() {
        XCTAssertFalse(preference.isShowStoreIdDebugView)
    }

    func test_TC1_토글을켜면_값이유지된다() {
        // When
        preference.isShowStoreIdDebugView = true

        // Then
        XCTAssertTrue(preference.isShowStoreIdDebugView)
        XCTAssertEqual(UserDefaults(suiteName: suiteName)?.bool(forKey: "KEY_DEBUG_SHOW_STORE_ID"), true)
    }

    func test_TC1_토글을껐다가다시읽으면_꺼짐이다() {
        // Given
        preference.isShowStoreIdDebugView = true

        // When
        preference.isShowStoreIdDebugView = false

        // Then
        XCTAssertFalse(preference.isShowStoreIdDebugView)
    }
}
