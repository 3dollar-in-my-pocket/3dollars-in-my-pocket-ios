import Foundation

public struct SDBorder: Decodable, Equatable, Hashable {
    public let color: String
    public let width: Double

    public init(color: String, width: Double) {
        self.color = color
        self.width = width
    }
}

public struct SDSurfaceStyle: Decodable, Hashable {
    public let backgroundColor: String
    /// 서버가 중첩 객체 형태(`border: {color, width}`)로 내려주는 표준 표현.
    public let border: SDBorder?
    /// flat 형태(`borderColor`, `borderWidth`)로 합성한 legacy 호출자 호환용. 서버 응답에는 보통 없음.
    public let borderColor: String?
    public let borderWidth: Double?
    public let cornerRadius: Double?

    public init(
        backgroundColor: String,
        border: SDBorder? = nil,
        borderColor: String? = nil,
        borderWidth: Double? = nil,
        cornerRadius: Double? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.border = border
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }
}
