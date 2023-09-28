// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum StoreStrings {

  public enum NavigationBottomSheet {
    /// 지도앱이 설치되어있지 않은 경우 정상적으로 실행되지 않습니다.
    public static let message = StoreStrings.tr("Localization", "navigation_bottom_sheet.message")
    /// 길 안내 앱 선택
    public static let title = StoreStrings.tr("Localization", "navigation_bottom_sheet.title")
    public enum Action {
      /// 취소
      public static let cancel = StoreStrings.tr("Localization", "navigation_bottom_sheet.action.cancel")
      /// 카카오 지도
      public static let kakaoMap = StoreStrings.tr("Localization", "navigation_bottom_sheet.action.kakao_map")
      /// 네이버 지도
      public static let naverMap = StoreStrings.tr("Localization", "navigation_bottom_sheet.action.naver_map")
    }
  }

  public enum ReportModal {
    /// 신고하기
    public static let button = StoreStrings.tr("Localization", "report_modal.button")
    /// 3건 이상의 요청이 들어오면 자동 삭제됩니다
    public static let description = StoreStrings.tr("Localization", "report_modal.description")
    /// 3건 이상
    public static let descriptionBold = StoreStrings.tr("Localization", "report_modal.description_bold")
    /// 삭제 요청 하시는 이유가 궁금해요!
    public static let title = StoreStrings.tr("Localization", "report_modal.title")
  }

  public enum ReviewBottomSheet {
    /// 리뷰를 남겨주세요!(100자 이내)
    public static let placeholder = StoreStrings.tr("Localization", "review_bottom_sheet.placeholder")
    /// 이 가게를 추천하시나요?
    public static let title = StoreStrings.tr("Localization", "review_bottom_sheet.title")
    /// 리뷰 쓰기
    public static let writeButton = StoreStrings.tr("Localization", "review_bottom_sheet.write_button")
  }

  public enum StoreDetail {
    public enum BottomSticky {
      /// 즐겨찾기
      public static let save = StoreStrings.tr("Localization", "store_detail.bottom_sticky.save")
      /// 방문 인증하기
      public static let visit = StoreStrings.tr("Localization", "store_detail.bottom_sticky.visit")
    }
    public enum Info {
      /// 출몰시기
      public static let appearanceDay = StoreStrings.tr("Localization", "store_detail.info.appearance_day")
      /// 금
      public static let friday = StoreStrings.tr("Localization", "store_detail.info.friday")
      /// 월
      public static let monday = StoreStrings.tr("Localization", "store_detail.info.monday")
      /// 결제방식
      public static let paymentMethod = StoreStrings.tr("Localization", "store_detail.info.payment_method")
      /// 토
      public static let saturday = StoreStrings.tr("Localization", "store_detail.info.saturday")
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
      public enum Header {
        /// 정보 수정
        public static let button = StoreStrings.tr("Localization", "store_detail.info.header.button")
        /// 가게 정보 & 메뉴
        public static let title = StoreStrings.tr("Localization", "store_detail.info.header.title")
      }
      public enum PaymentMethod {
        /// 계좌이체
        public static let accountTransfer = StoreStrings.tr("Localization", "store_detail.info.payment_method.account_transfer")
        /// 카드
        public static let card = StoreStrings.tr("Localization", "store_detail.info.payment_method.card")
        /// 현금
        public static let cash = StoreStrings.tr("Localization", "store_detail.info.payment_method.cash")
      }
      public enum SalesType {
        /// 편의점
        public static let convenienceStore = StoreStrings.tr("Localization", "store_detail.info.sales_type.convenience_store")
        /// 길거리
        public static let road = StoreStrings.tr("Localization", "store_detail.info.sales_type.road")
        /// 매장
        public static let store = StoreStrings.tr("Localization", "store_detail.info.sales_type.store")
      }
    }
    public enum Menu {
      /// 메뉴 더 보기
      public static let more = StoreStrings.tr("Localization", "store_detail.menu.more")
      /// 길 안내
      public static let navigation = StoreStrings.tr("Localization", "store_detail.menu.navigation")
      /// 리뷰쓰기
      public static let review = StoreStrings.tr("Localization", "store_detail.menu.review")
      /// 공유하기
      public static let share = StoreStrings.tr("Localization", "store_detail.menu.share")
    }
    public enum Overview {
      /// %@님 제보
      public static func repoterNameFormat(_ p1: Any) -> String {
        return StoreStrings.tr("Localization", "store_detail.overview.repoter_name_format", String(describing: p1))
      }
      /// 최근 한달 %d명이 방문 성공
      public static func successVisitCountFormat(_ p1: Int) -> String {
        return StoreStrings.tr("Localization", "store_detail.overview.success_visit_count_format", p1)
      }
    }
    public enum Photo {
      /// 더보기
      public static let more = StoreStrings.tr("Localization", "store_detail.photo.more")
      public enum Header {
        /// 사진 제보
        public static let button = StoreStrings.tr("Localization", "store_detail.photo.header.button")
        /// 가게 사진
        public static let title = StoreStrings.tr("Localization", "store_detail.photo.header.title")
      }
    }
    public enum Rating {
      /// 평균 별점
      public static let title = StoreStrings.tr("Localization", "store_detail.rating.title")
    }
    public enum Review {
      /// 수정
      public static let edit = StoreStrings.tr("Localization", "store_detail.review.edit")
      /// 리뷰 %d개 더보기
      public static func moreFormat(_ p1: Int) -> String {
        return StoreStrings.tr("Localization", "store_detail.review.more_format", p1)
      }
      /// 신고
      public static let report = StoreStrings.tr("Localization", "store_detail.review.report")
      public enum Header {
        /// 리뷰 쓰기
        public static let button = StoreStrings.tr("Localization", "store_detail.review.header.button")
        /// 리뷰
        public static let title = StoreStrings.tr("Localization", "store_detail.review.header.title")
      }
    }
    public enum Toast {
      /// 즐겨찾기가 추가되었습니다!
      public static let addFavorite = StoreStrings.tr("Localization", "store_detail.toast.add_favorite")
      /// 즐겨찾기가 삭제되었습니다!
      public static let removeFavorite = StoreStrings.tr("Localization", "store_detail.toast.remove_favorite")
    }
    public enum Visit {
      /// + 그 외 %d명이 다녀갔어요!
      public static func moreFormat(_ p1: Int) -> String {
        return StoreStrings.tr("Localization", "store_detail.visit.more_format", p1)
      }
      public enum Format {
        /// 방문 실패 %d명
        public static func visitFail(_ p1: Int) -> String {
          return StoreStrings.tr("Localization", "store_detail.visit.format.visit_fail", p1)
        }
        /// 방문 성공 %d명
        public static func visitSuccess(_ p1: Int) -> String {
          return StoreStrings.tr("Localization", "store_detail.visit.format.visit_success", p1)
        }
      }
      public enum Header {
        /// 아직 방문 인증 내역이 없어요 :(
        public static let titleEmpty = StoreStrings.tr("Localization", "store_detail.visit.header.title_empty")
        /// 이번 달 방문 인증 내역
        public static let titleNormal = StoreStrings.tr("Localization", "store_detail.visit.header.title_normal")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension StoreStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = StoreResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
