enum GAPage: String {
  
  case login_page = "login_page"
  case nickname_initialize_page = "nickname_initialize_page"
  case nickname_change_page = "nickname_change_page"
  case home_page = "home_page"
  case search_page = "search_page"
  case category_page = "category_page"
  case store_list_page = "store_list_page"
  case store_detail_page = "store_detail_page"
  case review_write = "review_write"
  case store_edit_page = "store_edit_page"
  case store_register_address_page = "store_register_address_page"
  case store_register_page = "store_register_page"
  case delete_request_popup = "delete_request_popup"
  case my_info_page = "my_info_page"
  case setting_page = "setting_page"
    /// 홈 화면 전면 팝업
    case splash_popup_page
    
    /// 푸드트럭 상세화면
    case boss_store_detail
}
