import XCTest

@testable import Write

final class OpeningHoursFormatterTests: XCTestCase {
    // MARK: TH-1451 TC1

    func test_TH1451_TC1_분이있는시간은_시와분까지표시된다() throws {
        // Given
        let date = try XCTUnwrap(makeDate(hour: 10, minute: 30))

        // When
        let text = OpeningHoursFormatter.string(from: date)

        // Then
        XCTAssertEqual(text, "오전 10시 30분")
    }

    func test_TH1451_TC1_오후시간도_시와분까지표시된다() throws {
        // Given
        let date = try XCTUnwrap(makeDate(hour: 19, minute: 5))

        // When
        let text = OpeningHoursFormatter.string(from: date)

        // Then
        XCTAssertEqual(text, "오후 7시 5분")
    }

    // MARK: TH-1451 TC2

    func test_TH1451_TC2_정각은_기존처럼시까지만표시된다() throws {
        // Given
        let date = try XCTUnwrap(makeDate(hour: 10, minute: 0))

        // When
        let text = OpeningHoursFormatter.string(from: date)

        // Then
        XCTAssertEqual(text, "오전 10시")
    }

    private func makeDate(hour: Int, minute: Int) -> Date? {
        Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 4, hour: hour, minute: minute))
    }
}
