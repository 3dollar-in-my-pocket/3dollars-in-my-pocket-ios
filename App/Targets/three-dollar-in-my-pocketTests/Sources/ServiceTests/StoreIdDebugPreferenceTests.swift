import XCTest

import Common

/// 설정 > "[디버그] 가게 ID 표시" 토글의 저장/복원.
///
/// 토글은 UserDefaults 에 남아서 앱을 다시 켜도 유지돼야 하고,
/// 한 번도 켠 적 없으면 기본값은 꺼짐이어야 한다.
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
        // UserDefaults 에 실제로 기록됐는지 확인한다.
        // (Preference(name:) 는 init 에서 도메인을 지우므로 새 인스턴스로 검증하면 안 된다)
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
