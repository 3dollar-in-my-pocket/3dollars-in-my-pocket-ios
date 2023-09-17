// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum CommunityStrings {

  public enum StoreDetail {
    public enum BottomSticky {
      /// 즐겨찾기
      public static let save = CommunityStrings.tr("Localization", "store_detail.bottom_sticky.save")
      /// 방문 인증하기
      public static let visit = CommunityStrings.tr("Localization", "store_detail.bottom_sticky.visit")
    }
    public enum Info {
      /// 출몰시기
      public static let appearanceDay = CommunityStrings.tr("Localization", "store_detail.info.appearance_day")
      /// 금
      public static let friday = CommunityStrings.tr("Localization", "store_detail.info.friday")
      /// 월
      public static let monday = CommunityStrings.tr("Localization", "store_detail.info.monday")
      /// 결제방식
      public static let paymentMethod = CommunityStrings.tr("Localization", "store_detail.info.payment_method")
      /// 토
      public static let saturday = CommunityStrings.tr("Localization", "store_detail.info.saturday")
      /// 가게형태
      public static let storeType = CommunityStrings.tr("Localization", "store_detail.info.store_type")
      /// 일
      public static let sunday = CommunityStrings.tr("Localization", "store_detail.info.sunday")
      /// 목
      public static let thursday = CommunityStrings.tr("Localization", "store_detail.info.thursday")
      /// 화
      public static let tuesday = CommunityStrings.tr("Localization", "store_detail.info.tuesday")
      /// 수
      public static let wednesday = CommunityStrings.tr("Localization", "store_detail.info.wednesday")
      public enum Header {
        /// 정보 수정
        public static let button = CommunityStrings.tr("Localization", "store_detail.info.header.button")
        /// 가게 정보 & 메뉴
        public static let title = CommunityStrings.tr("Localization", "store_detail.info.header.title")
      }
      public enum PaymentMethod {
        /// 계좌이체
        public static let accountTransfer = CommunityStrings.tr("Localization", "store_detail.info.payment_method.account_transfer")
        /// 카드
        public static let card = CommunityStrings.tr("Localization", "store_detail.info.payment_method.card")
        /// 현금
        public static let cash = CommunityStrings.tr("Localization", "store_detail.info.payment_method.cash")
      }
      public enum SalesType {
        /// 편의점
        public static let convenienceStore = CommunityStrings.tr("Localization", "store_detail.info.sales_type.convenience_store")
        /// 길거리
        public static let road = CommunityStrings.tr("Localization", "store_detail.info.sales_type.road")
        /// 매장
        public static let store = CommunityStrings.tr("Localization", "store_detail.info.sales_type.store")
      }
    }
    public enum Menu {
      /// 메뉴 더 보기
      public static let more = CommunityStrings.tr("Localization", "store_detail.menu.more")
      /// 길 안내
      public static let navigation = CommunityStrings.tr("Localization", "store_detail.menu.navigation")
      /// 리뷰쓰기
      public static let review = CommunityStrings.tr("Localization", "store_detail.menu.review")
      /// 공유하기
      public static let share = CommunityStrings.tr("Localization", "store_detail.menu.share")
    }
    public enum Overview {
      /// %@님 제보
      public static func repoterNameFormat(_ p1: Any) -> String {
        return CommunityStrings.tr("Localization", "store_detail.overview.repoter_name_format", String(describing: p1))
      }
      /// 최근 한달 %d명이 방문 성공
      public static func successVisitCountFormat(_ p1: Int) -> String {
        return CommunityStrings.tr("Localization", "store_detail.overview.success_visit_count_format", p1)
      }
    }
    public enum Photo {
      /// 더보기
      public static let more = CommunityStrings.tr("Localization", "store_detail.photo.more")
      public enum Header {
        /// 사진 제보
        public static let button = CommunityStrings.tr("Localization", "store_detail.photo.header.button")
        /// 가게 사진
        public static let title = CommunityStrings.tr("Localization", "store_detail.photo.header.title")
      }
    }
    public enum Rating {
      /// 평균 별점
      public static let title = CommunityStrings.tr("Localization", "store_detail.rating.title")
    }
    public enum Review {
      /// 수정
      public static let edit = CommunityStrings.tr("Localization", "store_detail.review.edit")
      /// 리뷰 %d개 더보기
      public static func moreFormat(_ p1: Int) -> String {
        return CommunityStrings.tr("Localization", "store_detail.review.more_format", p1)
      }
      /// 신고
      public static let report = CommunityStrings.tr("Localization", "store_detail.review.report")
      public enum Header {
        /// 리뷰 쓰기
        public static let button = CommunityStrings.tr("Localization", "store_detail.review.header.button")
        /// 리뷰
        public static let title = CommunityStrings.tr("Localization", "store_detail.review.header.title")
      }
    }
    public enum Visit {
      /// + 그 외 %d명이 다녀갔어요!
      public static func moreFormat(_ p1: Int) -> String {
        return CommunityStrings.tr("Localization", "store_detail.visit.more_format", p1)
      }
      public enum Format {
        /// 방문 실패 %d명
        public static func visitFail(_ p1: Int) -> String {
          return CommunityStrings.tr("Localization", "store_detail.visit.format.visit_fail", p1)
        }
        /// 방문 성공 %d명
        public static func visitSuccess(_ p1: Int) -> String {
          return CommunityStrings.tr("Localization", "store_detail.visit.format.visit_success", p1)
        }
      }
      public enum Header {
        /// 아직 방문 인증 내역이 없어요 :(
        public static let titleEmpty = CommunityStrings.tr("Localization", "store_detail.visit.header.title_empty")
        /// 이번 달 방문 인증 내역
        public static let titleNormal = CommunityStrings.tr("Localization", "store_detail.visit.header.title_normal")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension CommunityStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = CommunityResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
