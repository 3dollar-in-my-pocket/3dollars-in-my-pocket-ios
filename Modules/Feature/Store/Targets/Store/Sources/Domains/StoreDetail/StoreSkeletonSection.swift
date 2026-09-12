import Model

/// 서버 섹션이 아니라 클라이언트가 끼워 넣는 플레이스홀더.
/// 바텀시트가 full 로 올라가는 동안 미리보기 데이터로 만든 PREVIEW 셀 아래에 붙여, 상세 응답이 오기 전까지 자리를 채운다.
struct StoreSkeletonSection: StoreSectionComponent {
    var type: StoreSectionType { .unknown }
}
