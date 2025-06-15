import Foundation

public protocol StoreDetailComponent: Equatable, Hashable, Decodable {
    var type: StoreDetailComponentType { get }
    var sectionId: String { get }
}

public enum StoreDetailComponentType: String, Decodable {
    case storeAccountNumber = "STORE_ACCOUNT_NUMBER"
    case storeActionBar = "STORE_ACTION_BAR"
    case storeAdmobCard = "STORE_ADMOB_CARD"
    case storeCategorizedMenus = "STORE_CATEGORIZED_MENUS"
    case storeImageMenus = "STORE_IMAGE_MENUS"
    case storeImages = "STORE_IMAGES"
    case storeInfo = "STORE_INFO"
    case storeMap = "STORE_MAP"
    case storeNews = "STORE_NEWS"
    case storeOpeningDays = "STORE_OPENING_DAYS"
    case storeOverview = "STORE_OVERVIEW"
    case storeReviews = "STORE_REVIEWS"
    case storeVisits = "STORE_VISITS"
    case basicStoreInfo = "BASIC_STORE_INFO"
    case unknown
    
    public init(from decoder: Decoder) throws {
        let rawValue = try? decoder.singleValueContainer().decode(RawValue.self)
        self = StoreDetailComponentType(rawValue: rawValue ?? "") ?? .unknown
    }
}

/// [사장님 가게] 계좌 정보 컴포넌트
public struct StoreAccountNumberSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let title: SDText
    public let bank: SDText
    public let accountNumber: SDText?
    public let accountHolder: SDText?
    public let button: SDButton?
}

/// [길거리 음식점 / 사장님 가게] 상단 액션바 (북마크, 공유하기, 길안내, SNS)
public struct StoreActionBarSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let favorite: StoreActionBarFavoriteSectionResponse
    
    public struct StoreActionBarFavoriteSectionResponse: Decodable, Hashable {
        public let favoriteCount: Int
        public let isFavorite: Bool
    }
}

/// [길거리 음식점 / 사장님 가게] 애드몹 컴포넌트
public struct StoreAdmobCardSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
}

/// [길거리 음식점] 메뉴 컴포넌트
public struct StoreCategorizedMenusSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let menus: [StoreCategorizedMenuSectionResponse]
    
    public struct StoreCategorizedMenuSectionResponse: Decodable, Hashable {
        public let category: SDChip
        public let menus: [StoreInfoMenuItemSectionResponse]
        
        public struct StoreInfoMenuItemSectionResponse: Decodable, Hashable {
            public let name: SDText
            public let price: SDText?
        }
    }
}

/// [사장님 음식점] 이미지 메뉴 컴포넌트
public struct StoreImageMenusSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let menus: [StoreImageMenuSectionResponse]
    
    public struct StoreImageMenuSectionResponse: Decodable, Hashable {
        public let image: SDImage
        public let title: SDText
        public let subTitle: SDText?
    }
}

/// [길거리 음식점] 가게 이미지 컴포넌트
public struct StoreImagesSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let header: HeaderSectionResponse
    public let cards: [SDImage]
    public let more: StoreImageMoreSectionResponse?
    
    public struct StoreImageMoreSectionResponse: Decodable, Hashable {
        public let title: SDText
        public let subTitle: SDText?
    }
}

// TODO: 가게 정보 컴포넌트 서버 변경에 따라 적용 필요
public struct StoreInfoSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let title: SDText
    public let subTitle: SDText?
    public let updateButton: SDText?
    public let representativeImages: [SDImage]?
}

/// [길거리 음식점/ 사장님 가게] 지도 컴포넌트
public struct StoreMapSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let location: LocationResponse
    public let addressName: SDText?
}

/// [사장님 가게] 가게 소식 컴포넌트
public struct StoreNewsSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let title: SDText
    public let cards: [StoreNewsCardSectionResponse]
    
    public struct StoreNewsCardSectionResponse: Decodable, Hashable {
        public let title: SDText
        public let subTitle: SDText?
        public let thumbnail: SDImage?
        public let images: [SDImage]
        public let content: SDText
        public let likeButton: LikeSectionResponse?
        public let moreButton: SDText?
        
        public struct LikeSectionResponse: Decodable, Hashable {
            public let button: SDButton
            public let isSelected: Bool
        }
    }
}

/// [사장님 가게] 영업일 정보 컴포넌트
public struct StoreOpeningDaysSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let title: SDText
    public let openingDays: [StoreOpeningDaySectionResponse]
    
    public struct StoreOpeningDaySectionResponse: Decodable, Hashable {
        public let dayOfTheWeek: SDText
        public let opeingTime: SDText
        public let placeDescription: SDText?
    }
}

/// [길거리 음식점 / 사장님 가게] 가게 개요 정보 컴포넌트
public struct StoreOverviewSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let title: SDText?
    public let subTitle: SDText?
    public let image: SDImage?
    public let labels: [SDChip]
    public let metadata: [SDChip]
    public let badge: SDImage?
}

/// [공통] 리뷰 목록 컴포넌트
public struct StoreReviewsSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let title: SDText
    public let writeButton: SDText?
    public let overview: StoreReviewOverviewSectionResponse
    public let feedback: FeedbacksSectionResponse?
    public let reviews: [StoreReviewSectionResponse]
    public let more: SDText?
    
    public struct StoreReviewOverviewSectionResponse: Decodable, Hashable {
        public let title: SDText?
        public let star: Int
    }
    
    public struct FeedbacksSectionResponse: Decodable, Hashable {
        public let title: SDText
        public let feedbacks: [SDChip]
        public let moreButton: SDChip?
    }

    public struct StoreReviewSectionResponse: Decodable, Hashable {
        public let title: SDText
        public let subTitle: SDText
        public let button: StoreReviewButtonSectionResponse?
        public let badge: SDChip?
        public let star: Double
        public let images: [SDImage]?
        public let content: SDText?
        public let like: LikeSectionResponse?
        public let reply: [StoreReviewReplyCardSectionResponse]
        
        public struct StoreReviewButtonSectionResponse: Decodable, Hashable {
            public let title: SDText
            public let type: StoreReviewButtonType
            
            public enum StoreReviewButtonType: String, Decodable {
                case delete = "DELETE"
                case report = "REPORT"
            }
        }
        
        public struct LikeSectionResponse: Decodable, Hashable {
            public let button: SDButton
            public let isSelected: Bool
        }
        
        public struct StoreReviewReplyCardSectionResponse: Decodable, Hashable {
            public let title: SDText
            public let subTitle: SDText
            public let content: SDText
        }
    }
}

/// [길거리 음식점] 방문 인증 컴포넌트
public struct StoreVisitsSectionResponse: StoreDetailComponent {
    public let type: StoreDetailComponentType
    public let sectionId: String
    public let title: SDText?
    public let overview: StoreVisitsOverViewSectionResponse?
    public let visitCard: [StoreVisitCardSectionResponse]
    public let more: SDText?
    
    public struct StoreVisitsOverViewSectionResponse: Decodable, Hashable {
        public let success: SDChip
        public let failure: SDChip
    }
    
    public struct StoreVisitCardSectionResponse: Decodable, Hashable {
        public let icon: SDImage?
        public let title: SDText
        public let subTitle: SDText
    }
}

public struct HeaderSectionResponse: Decodable, Hashable {
    public let title: SDText
    public let subTitle: SDText?
    public let rightButton: SDButton?
}
