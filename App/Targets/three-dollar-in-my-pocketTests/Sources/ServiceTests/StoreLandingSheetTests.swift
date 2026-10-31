import XCTest

@testable import dollar_in_my_pocket

final class StoreLandingSheetTests: XCTestCase {

    // MARK: TH-1536 TC3

    func test_TH1536_TC3_view가collapsed면_접힘으로랜딩한다() {
        XCTAssertEqual(StoreLandingSheet(param: "collapsed"), .collapsed)
    }

    // MARK: TH-1536 TC4

    func test_TH1536_TC4_view가expanded면_펼침으로랜딩한다() {
        XCTAssertEqual(StoreLandingSheet(param: "expanded"), .expanded)
    }

    // MARK: TH-1536 TC5

    func test_TH1536_TC5_view가없거나알수없는값이면_프리뷰로랜딩한다() {
        XCTAssertEqual(StoreLandingSheet(param: nil), .collapsed)
        XCTAssertEqual(StoreLandingSheet(param: "unknown"), .collapsed)
    }
}
