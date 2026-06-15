import Foundation

public struct StorePreviewSection: Decodable, Hashable, StoreCardComponent {
    public let type: SDComponentType
    public let header: StorePreviewHeader
    public let metadata: StorePreviewMetadata
    public let actionBars: [StorePreviewActionBar]
    public let images: [SDImage]
    public let bodies: [StorePreviewBody]
    public let style: SDSurfaceStyle?
    public let additionalInfos: StorePreviewAdditionalInfos?
}

public struct StorePreviewAdditionalInfos: Decodable, Equatable, Hashable {
    /// 미리보기 데이터 종류 (STORE / EMPTY)
    public let type: String
    /// 가게 종류 (USER_STORE / BOSS_STORE). 가게 상세 진입 시 일반/사장님 화면 분기에 사용한다.
    public let storeType: String?
    /// 즐겨찾기(찜) 여부. 우상단 저장 버튼의 초기 선택 상태로 사용한다.
    public let isSubscriber: Bool
}

public struct StorePreviewHeader: Decodable, Equatable, Hashable {
    public let title: SDText?
    public let badge: SDImage?
}

public struct StorePreviewMetadata: Decodable, Equatable, Hashable {
    public let primary: [SDChip]
    public let secondary: [SDChip]
    public let separator: SDImage
}

public struct StorePreviewActionBar: Decodable, Equatable, Hashable {
    public let button: SDButton
    public let clickLog: SDClickLog
}

public struct StorePreviewBody: Decodable, Equatable, Hashable {
    public let text: SDText
    public let style: SDSurfaceStyle
}
