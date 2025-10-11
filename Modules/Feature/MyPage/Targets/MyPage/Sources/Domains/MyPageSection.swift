import UIKit

import Combine
import Model
import DesignSystem

// MARK: - Section Model

struct MyPageSection: Hashable {
    var type: MyPageSectionType
    var items: [MyPageSectionItem]
    var headerViewModel: MyPageSectionHeaderViewModel?

    static func == (lhs: MyPageSection, rhs: MyPageSection) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.overview, .overview):
            return true
        case (.visitStore, .visitStore):
            return true
        case (.favoriteStore, .favoriteStore):
            return true
        case (.poll, .poll):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch type {
        case .overview:
            hasher.combine("overview")
        case .visitStore, .favoriteStore, .poll, .coupon:
            hasher.combine(headerViewModel)
        }
    }
}

// MARK: - Section Type

enum MyPageSectionType {
    case overview
    case visitStore
    case favoriteStore
    case poll
    case coupon
    
    var icon: UIImage? {
        switch self {
        case .overview:
            return nil
        case .visitStore:
            return Icons.badge.image
        case .favoriteStore:
            return Icons.bookmarkSolid.image
        case .poll:
            return Icons.fireSolid.image
        case .coupon:
            return Icons.fireSolid.image
        }
    }
    
    var iconLabel: String? {
        switch self {
        case .overview:
            return nil
        case .visitStore:
            return "방문인증"
        case .favoriteStore:
            return "즐겨찾기"
        case .poll:
            return "맛대맛 투표" // TODO: API
        case .coupon:
            return "쿠폰"
        }
    }
    
    var title: String? {
        switch self {
        case .overview:
            return nil
        case .visitStore:
            return "내가 방문한 가게 알아보기"
        case .favoriteStore:
            return "내가 좋아하는 가게는?"
        case .poll:
            return "내가 만든 투표의 히스토리"
        case .coupon:
            return "아 맞다! 쿠폰 안쓰고 지나갈 뻔"
        }
    }
    
    var emptyIcon: UIImage? {
        switch self {
        case .overview:
            return nil
        case .visitStore:
            return Icons.fireSolid.image
        case .favoriteStore:
            return Icons.bookmarkSolid.image
        case .poll:
            return Icons.fireSolid.image
        case .coupon:
            return Icons.fireSolid.image
        }
    }
    
    var emptyTitle: String? {
        switch self {
        case .overview:
            return nil
        case .visitStore:
            return "방문인증 내역이 없어요"
        case .favoriteStore:
            return "즐겨찾기 리스트가 없어요"
        case .poll:
            return "내가 올린 투표가 없어요"
        case .coupon:
            return "발급받은 쿠폰이 없어요"
        }
    }
    
    var emptyDescription: String? {
        switch self {
        case .overview:
            return nil
        case .visitStore:
            return "방문 인증으로 정확도를 높혀봐요"
        case .favoriteStore:
            return "가게 상세에서 추가해 보세요"
        case .poll:
            return "투표 상세에서 추가해 보세요"
        case .coupon:
            return "쿠폰을 발급받을 수 있는 사장님 직영점을 찾아보세요"
        }
    }
}

// MARK: Section Item

enum MyPageSectionItem: Hashable {
    case overview(MyPageOverviewCellViewModel)
    case visitStore(MyPageStoreListCellViewModel)
    case favoriteStore(MyPageStoreListCellViewModel)
    case empty(MyPageSectionType)
    case pollTotalParticipantsCount(Int)
    case poll(data: PollApiResponse, isFirst: Bool, isLast: Bool)
    case coupon(MyPageStoreListCellViewModel)

    var identifier: String { // TODO
        switch self {
        case .overview(let viewModel):
            return String(viewModel.identifier.hashValue)
        case .visitStore(let viewModel):
            return String(viewModel.identifier.hashValue)
        case .favoriteStore(let viewModel):
            return String(viewModel.identifier.hashValue)
        case .empty:
            return "empty"
        case .pollTotalParticipantsCount:
            return "pollTotalParticipantsCount"
        case .poll(let data, _, _):
            return data.pollId
        case .coupon(let viewModel):
            return String(viewModel.identifier.hashValue)
        }
    }

    static func == (lhs: MyPageSectionItem, rhs: MyPageSectionItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
