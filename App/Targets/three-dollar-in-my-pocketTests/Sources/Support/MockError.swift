import Foundation

/// 목에서 스텁하지 않은 메서드가 호출됐을 때 반환하는 에러.
/// fatalError 대신 실패 Result로 흘려서 어떤 메서드가 예상 밖으로 호출됐는지 테스트 실패 메시지로 드러낸다.
enum MockError: Error, Equatable {
    case notStubbed(function: String)

    /// 호출한 메서드 이름을 자동으로 담는다: `.failure(MockError.notStubbed())`
    static func notStubbed(_ function: String = #function) -> MockError {
        .notStubbed(function: function)
    }
}
