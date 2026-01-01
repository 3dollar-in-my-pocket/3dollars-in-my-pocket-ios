// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum StoreStrings: Sendable {

  public enum BossStoreDetail: Sendable {

    public enum Feedback: Sendable {
    /// 리뷰 남기기
      public static let sendFeedback = StoreStrings.tr("Localization", "boss_store_detail.feedback.send_feedback")
      /// 가게 평가
      public static let title = StoreStrings.tr("Localization", "boss_store_detail.feedback.title")
    }

    public enum Info: Sendable {
    /// 계좌번호
      public static let accountTitle = StoreStrings.tr("Localization", "boss_store_detail.info.account_title")
      /// 연락처
      public static let contact = StoreStrings.tr("Localization", "boss_store_detail.info.contact")
      /// 복사하기
      public static let copy = StoreStrings.tr("Localization", "boss_store_detail.info.copy")
      /// 🔗 계좌번호가 복사되었습니다.
      public static let copyToast = StoreStrings.tr("Localization", "boss_store_detail.info.copy_toast")
      /// 사장님 한마디
      public static let introduction = StoreStrings.tr("Localization", "boss_store_detail.info.introduction")
      /// SNS
      public static let sns = StoreStrings.tr("Localization", "boss_store_detail.info.sns")
      /// 가게 정보 & 메뉴
      public static let title = StoreStrings.tr("Localization", "boss_store_detail.info.title")
      /// 업데이트
      public static let update = StoreStrings.tr("Localization", "boss_store_detail.info.update")
    }

    public enum Menu: Sendable {
    /// 등록된 메뉴가 없습니다.\n사장님이 메뉴를 등록할 때 까지 잠시만 기다려주세요!
      public static let empty = StoreStrings.tr("Localization", "boss_store_detail.menu.empty")
      /// 메뉴 %d개 더보기
      public static func menuMoreFormat(_ p1: Int) -> String {
        return StoreStrings.tr("Localization", "boss_store_detail.menu.menu_more_format",p1)
      }
      /// %@원
      public static func priceFormat(_ p1: Any) -> String {
        return StoreStrings.tr("Localization", "boss_store_detail.menu.price_format",String(describing: p1))
      }
    }

    public enum Sns: Sendable {
    /// SNS 주소가 없습니다🥲
      public static let empty = StoreStrings.tr("Localization", "boss_store_detail.sns.empty")
    }

    public enum Workday: Sendable {
    /// 휴무
      public static let closed = StoreStrings.tr("Localization", "boss_store_detail.workday.closed")
      /// 영업 일정
      public static let title = StoreStrings.tr("Localization", "boss_store_detail.workday.title")
    }
  }

  public enum BossStoreFeedback: Sendable {
  /// 소중한 리뷰가 사장님께 전달되었습니다!
    public static let finishToast = StoreStrings.tr("Localization", "boss_store_feedback.finish_toast")
    /// 리뷰 남기기 완료!
    public static let sendFeedback = StoreStrings.tr("Localization", "boss_store_feedback.send_feedback")
    /// 리뷰 남기기
    public static let title = StoreStrings.tr("Localization", "boss_store_feedback.title")

    public enum Content: Sendable {
    /// 여러개의 리뷰를 선택할 수 있습니다.
      public static let subtitle = StoreStrings.tr("Localization", "boss_store_feedback.content.subtitle")
      /// 음식은 어떠셨나요?
      public static let title = StoreStrings.tr("Localization", "boss_store_feedback.content.title")
    }
  }

  public enum MapDetail: Sendable {
  /// 길 안내보기
    public static let navigationButton = StoreStrings.tr("Localization", "map_detail.navigation_button")
    /// 지도 보기
    public static let title = StoreStrings.tr("Localization", "map_detail.title")
  }

  public enum NavigationBottomSheet: Sendable {
  /// 지도앱이 설치되어있지 않은 경우 정상적으로 실행되지 않습니다.
    public static let message = StoreStrings.tr("Localization", "navigation_bottom_sheet.message")
    /// 길 안내 앱 선택
    public static let title = StoreStrings.tr("Localization", "navigation_bottom_sheet.title")

    public enum Action: Sendable {
    /// 애플 지도
      public static let appleMap = StoreStrings.tr("Localization", "navigation_bottom_sheet.action.apple_map")
      /// 취소
      public static let cancel = StoreStrings.tr("Localization", "navigation_bottom_sheet.action.cancel")
      /// 카카오 지도
      public static let kakaoMap = StoreStrings.tr("Localization", "navigation_bottom_sheet.action.kakao_map")
      /// 네이버 지도
      public static let naverMap = StoreStrings.tr("Localization", "navigation_bottom_sheet.action.naver_map")
    }
  }

  public enum PhotoDetail: Sendable {

    public enum Delete: Sendable {
    /// 삭제
      public static let delete = StoreStrings.tr("Localization", "photo_detail.delete.delete")
      /// 정말로 사진을 삭제하시겠습니까?
      public static let title = StoreStrings.tr("Localization", "photo_detail.delete.title")
    }
  }

  public enum PhotoList: Sendable {
  /// 사진
    public static let title = StoreStrings.tr("Localization", "photo_list.title")
    /// 사진 제보하기
    public static let uploadButton = StoreStrings.tr("Localization", "photo_list.upload_button")
  }

  public enum ReportModal: Sendable {
  /// 신고하기
    public static let button = StoreStrings.tr("Localization", "report_modal.button")
    /// 3건 이상의 요청이 들어오면 자동 삭제됩니다
    public static let description = StoreStrings.tr("Localization", "report_modal.description")
    /// 3건 이상
    public static let descriptionBold = StoreStrings.tr("Localization", "report_modal.description_bold")
    /// 삭제 요청 하시는 이유가 궁금해요!
    public static let title = StoreStrings.tr("Localization", "report_modal.title")
  }

  public enum ReportReviewBottomSheet: Sendable {
  /// 신고 사유 직접 입력
    public static let placeholder = StoreStrings.tr("Localization", "report_review_bottom_sheet.placeholder")
    /// 신고하기
    public static let report = StoreStrings.tr("Localization", "report_review_bottom_sheet.report")
    /// 신고 사유
    public static let title = StoreStrings.tr("Localization", "report_review_bottom_sheet.title")
  }

  public enum ReviewBottomSheet: Sendable {
  /// 리뷰를 남겨주세요!(100자 이내)
    public static let placeholder = StoreStrings.tr("Localization", "review_bottom_sheet.placeholder")
    /// 이 가게를 추천하시나요?
    public static let title = StoreStrings.tr("Localization", "review_bottom_sheet.title")
    /// 리뷰 쓰기
    public static let writeButton = StoreStrings.tr("Localization", "review_bottom_sheet.write_button")
  }

  public enum ReviewList: Sendable {
  /// 규정 위반으로 블라인드 처리되었습니다.
    public static let filtered = StoreStrings.tr("Localization", "review_list.filtered")
    /// 리뷰
    public static let title = StoreStrings.tr("Localization", "review_list.title")
    /// 리뷰 작성하기
    public static let writeReview = StoreStrings.tr("Localization", "review_list.write_review")

    public enum Alert: Sendable {
    /// 리뷰를 삭제하시겠습니까?
      public static let delete = StoreStrings.tr("Localization", "review_list.alert.delete")
    }

    public enum SortType: Sendable {
    /// 별점 높은순
      public static let highestRating = StoreStrings.tr("Localization", "review_list.sort_type.highest_rating")
      /// 최신순
      public static let latest = StoreStrings.tr("Localization", "review_list.sort_type.latest")
      /// 별점 낮은순
      public static let lowestRating = StoreStrings.tr("Localization", "review_list.sort_type.lowest_rating")
    }
  }

  public enum StoreDetail: Sendable {
  /// 가슴속 3천원이 직접 확인한 공식 인증가게입니다!
    public static let verified = StoreStrings.tr("Localization", "store_detail.verified")

    public enum BottomSticky: Sendable {
    /// 즐겨찾기
      public static let save = StoreStrings.tr("Localization", "store_detail.bottom_sticky.save")
      /// 방문 인증하기
      public static let visit = StoreStrings.tr("Localization", "store_detail.bottom_sticky.visit")
    }

    public enum Info: Sendable {
    /// 출몰시기
      public static let appearanceDay = StoreStrings.tr("Localization", "store_detail.info.appearance_day")
      /// 제보가 필요해요😢
      public static let emptyOpeningHours = StoreStrings.tr("Localization", "store_detail.info.empty_opening_hours")
      /// a h시까지
      public static let endTimeFormat = StoreStrings.tr("Localization", "store_detail.info.end_time_format")
      /// 금
      public static let friday = StoreStrings.tr("Localization", "store_detail.info.friday")
      /// 월
      public static let monday = StoreStrings.tr("Localization", "store_detail.info.monday")
      /// 출몰 시간대
      public static let openingHours = StoreStrings.tr("Localization", "store_detail.info.opening_hours")
      /// 결제방식
      public static let paymentMethod = StoreStrings.tr("Localization", "store_detail.info.payment_method")
      /// 토
      public static let saturday = StoreStrings.tr("Localization", "store_detail.info.saturday")
      /// a h시부터
      public static let startTimeFormat = StoreStrings.tr("Localization", "store_detail.info.start_time_format")
      /// 가게형태
      public static let storeType = StoreStrings.tr("Localization", "store_detail.info.store_type")
      /// 일
      public static let sunday = StoreStrings.tr("Localization", "store_detail.info.sunday")
      /// 목
      public static let thursday = StoreStrings.tr("Localization", "store_detail.info.thursday")
      /// 화
      public static let tuesday = StoreStrings.tr("Localization", "store_detail.info.tuesday")
      /// 수
      public static let wednesday = StoreStrings.tr("Localization", "store_detail.info.wednesday")

      public enum Header: Sendable {
      /// 정보 수정
        public static let button = StoreStrings.tr("Localization", "store_detail.info.header.button")
        /// 가게 정보 & 메뉴
        public static let title = StoreStrings.tr("Localization", "store_detail.info.header.title")
      }

      public enum PaymentMethod: Sendable {
      /// 계좌이체
        public static let accountTransfer = StoreStrings.tr("Localization", "store_detail.info.payment_method.account_transfer")
        /// 카드
        public static let card = StoreStrings.tr("Localization", "store_detail.info.payment_method.card")
        /// 현금
        public static let cash = StoreStrings.tr("Localization", "store_detail.info.payment_method.cash")
      }

      public enum SalesType: Sendable {
      /// 편의점
        public static let convenienceStore = StoreStrings.tr("Localization", "store_detail.info.sales_type.convenience_store")
        /// 푸드트럭
        public static let foodTruck = StoreStrings.tr("Localization", "store_detail.info.sales_type.food_truck")
        /// 길거리
        public static let road = StoreStrings.tr("Localization", "store_detail.info.sales_type.road")
        /// 매장
        public static let store = StoreStrings.tr("Localization", "store_detail.info.sales_type.store")
      }
    }

    public enum Menu: Sendable {
    /// 메뉴 더 보기
      public static let more = StoreStrings.tr("Localization", "store_detail.menu.more")
      /// 길 안내
      public static let navigation = StoreStrings.tr("Localization", "store_detail.menu.navigation")
      /// 리뷰쓰기
      public static let review = StoreStrings.tr("Localization", "store_detail.menu.review")
      /// 공유하기
      public static let share = StoreStrings.tr("Localization", "store_detail.menu.share")
    }

    public enum Overview: Sendable {
    /// %@님 제보
      public static func repoterNameFormat(_ p1: Any) -> String {
        return StoreStrings.tr("Localization", "store_detail.overview.repoter_name_format",String(describing: p1))
      }
      /// 최근 한달 %d명이 방문 성공
      public static func successVisitCountFormat(_ p1: Int) -> String {
        return StoreStrings.tr("Localization", "store_detail.overview.success_visit_count_format",p1)
      }
    }

    public enum Photo: Sendable {
    /// 사진을 제보해주세요!
      public static let empty = StoreStrings.tr("Localization", "store_detail.photo.empty")
      /// 더보기
      public static let more = StoreStrings.tr("Localization", "store_detail.photo.more")

      public enum Header: Sendable {
      /// 사진 제보
        public static let button = StoreStrings.tr("Localization", "store_detail.photo.header.button")
        /// 가게 사진
        public static let title = StoreStrings.tr("Localization", "store_detail.photo.header.title")
      }
    }

    public enum Rating: Sendable {
    /// 평균 별점
      public static let title = StoreStrings.tr("Localization", "store_detail.rating.title")
    }

    public enum Review: Sendable {
    /// 수정
      public static let edit = StoreStrings.tr("Localization", "store_detail.review.edit")
      /// 리뷰를 작성해주세요.
      public static let empty = StoreStrings.tr("Localization", "store_detail.review.empty")
      /// 리뷰 %d개 더보기
      public static func moreFormat(_ p1: Int) -> String {
        return StoreStrings.tr("Localization", "store_detail.review.more_format",p1)
      }
      /// 신고
      public static let report = StoreStrings.tr("Localization", "store_detail.review.report")

      public enum Header: Sendable {
      /// 리뷰 쓰기
        public static let button = StoreStrings.tr("Localization", "store_detail.review.header.button")
        /// 리뷰
        public static let title = StoreStrings.tr("Localization", "store_detail.review.header.title")
      }
    }

    public enum Toast: Sendable {
    /// 즐겨찾기가 추가되었습니다!
      public static let addFavorite = StoreStrings.tr("Localization", "store_detail.toast.add_favorite")
      /// 🔗 주소를 클립보드에 복사했습니다.
      public static let copyToAddress = StoreStrings.tr("Localization", "store_detail.toast.copy_to_address")
      /// 즐겨찾기가 삭제되었습니다!
      public static let removeFavorite = StoreStrings.tr("Localization", "store_detail.toast.remove_favorite")
    }

    public enum Tooltip: Sendable {
    /// 북마크를 하고 사장님의 메세지를 받아보세요!
      public static let bookmark = StoreStrings.tr("Localization", "store_detail.tooltip.bookmark")
    }

    public enum Verified: Sendable {
    /// 공식 인증
      public static let bold = StoreStrings.tr("Localization", "store_detail.verified.bold")
    }

    public enum Visit: Sendable {
    /// + 그 외 %d명이 다녀갔어요!
      public static func moreFormat(_ p1: Int) -> String {
        return StoreStrings.tr("Localization", "store_detail.visit.more_format",p1)
      }

      public enum Empty: Sendable {
      /// 최근 활동 소식은 사장님과 유저들에게\n도움을 줄 수 있습니다 :)
        public static let description = StoreStrings.tr("Localization", "store_detail.visit.empty.description")
        /// 방문 인증으로 가게의 최근 활동을 알려주세요!
        public static let title = StoreStrings.tr("Localization", "store_detail.visit.empty.title")
      }

      public enum Format: Sendable {
      /// 방문 실패 %d명
        public static func visitFail(_ p1: Int) -> String {
          return StoreStrings.tr("Localization", "store_detail.visit.format.visit_fail",p1)
        }
        /// 방문 성공 %d명
        public static func visitSuccess(_ p1: Int) -> String {
          return StoreStrings.tr("Localization", "store_detail.visit.format.visit_success",p1)
        }
      }

      public enum Header: Sendable {
      /// 아직 방문 인증 내역이 없어요 :(
        public static let titleEmpty = StoreStrings.tr("Localization", "store_detail.visit.header.title_empty")
        /// 이번 달 방문 인증 내역
        public static let titleNormal = StoreStrings.tr("Localization", "store_detail.visit.header.title_normal")
      }
    }
  }

  public enum UploadPhoto: Sendable {

    public enum AuthErrorAlert: Sendable {
    /// 사진 제보를 위해 앨범 권한이 필요합니다.
      public static let message = StoreStrings.tr("Localization", "upload_photo.auth_error_alert.message")
    }

    public enum Button: Sendable {
    /// 총 %d장 / %d장 의 사진 등록
      public static func titleFormat(_ p1: Int, _ p2: Int) -> String {
        return StoreStrings.tr("Localization", "upload_photo.button.title_format",p1, p2)
      }
    }
  }

  public enum Visit: Sendable {
  /// 인증까지 %dm
    public static func distanceFormat(_ p1: Int) -> String {
      return StoreStrings.tr("Localization", "visit.distance_format",p1)
    }
    /// 방문 성공
    public static let exists = StoreStrings.tr("Localization", "visit.exists")
    /// 방문 실패
    public static let notExists = StoreStrings.tr("Localization", "visit.not_exists")
    /// 방문 기록을 저장했습니다👍
    public static let resultMessage = StoreStrings.tr("Localization", "visit.result_message")

    public enum Title: Sendable {
    /// 가게 도착!\n방문을 인증해보세요!
      public static let exists = StoreStrings.tr("Localization", "visit.title.exists")
      /// 가게 도착!
      public static let existsBold = StoreStrings.tr("Localization", "visit.title.exists_bold")
      /// 가게 근처에서\n방문을 인증할 수 있어요!
      public static let notExists = StoreStrings.tr("Localization", "visit.title.not_exists")
      /// 가게 근처
      public static let notExistsBold = StoreStrings.tr("Localization", "visit.title.not_exists_bold")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension StoreStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
