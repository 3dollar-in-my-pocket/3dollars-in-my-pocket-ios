enum GAEvent: String {
  
  // shared
  case back_button_clicked = "back_button_clicked"
  case close_button_clicked = "close_button_clicked"
  case current_location_button_clicked = "current_location_button_clicked"
  case toss_button_clicked = "toss_button_clicked"
  
  case kakao_login_button_clicked = "kakao_login_button_clicked"
  case apple_login_button_clicked = "apple_login_button_clicked"
  
  case nickname_change_button_clicked = "nickname_change_button_clicked"
  case nickname_already_existed = "nickname_already_existed"
    
    /// 홈 화면 전면 팝업 터치
    case splash_popup_clicked
  
  // home_page
  case search_button_clicked = "search_button_clicked"
  case store_card_button_clicked = "store_card_button_clicked"
  
  // search_page
  case location_item_clicked = "location_item_clicked"
  
    /// 카테고리 화면 상단 배너 터치
    case category_banner_clicked
    
  case bungeoppang_button_clicked = "bungeoppang_button_clicked"
  case takoyaki_button_clicked = "takoyaki_button_clicked"
  case gyeranppang_button_clicked = "gyeranppang_button_clicked"
  case hotteok_button_clicked = "hotteok_button_clicked"
  case eomuk_button_clicked = "eomuk_button_clicked"
  case gungoguma_button_clicked = "gungoguma_button_clicked"
  case tteokbokki_button_clicked = "tteokbokki_button_clicked"
  case ttangkongppang_button_clicked = "ttangkongppang_button_clicked"
  case gunoksusu_button_clicked = "gunoksusu_button_clicked"
  case kkochi_button_clicked = "kkochi_button_clicked"
  case toast_button_clicked = "toast_button_clicked"
  case waffle_button_clicked = "waffle_button_clicked"
  case gukwappang_button_clicked = "gukwappang_button_clicked"
  case sundae_button_clicked = "sundae_button_clicked"
  case dalgona_button_clicked = "dalgona_button_clicked"
  
  // store_list_page
  case order_by_distance_button_list = "order_by_distance_button_list"
  case order_by_rating_button_list = "order_by_rating_button_list"
  case store_list_item_clicked = "store_list_item_clicked"
  
  // store_detail_page
  case store_delete_request_button_clicked = "store_delete_request_button_clicked"
  case share_button_clicked = "share_button_clicked"
  case store_modify_button_clicked = "store_modify_button_clicked"
  case image_attach_button_clicked = "image_attach_button_clicked"
  case review_write_button_clicked = "review_write_button_clicked"
  
  // review_write
  case review_write_close_button_clicked = "review_write_close_button_clicked"
  case star_button_clicked = "star_button_clicked"
  case review_register_button_clicked = "review_register_button_clicked"
  
  // store_edit_page
  case address_edit_button_clicked = "address_edit_button_clicked"
  case store_edit_submit_button_clicked = "store_edit_submit_button_clicked"
  
  // store_register_address_page
  case set_address_button_clicked = "set_address_button_clicked"
  
  // store_register_page
  case edit_address_button_clicked = "edit_address_button_clicked"
  case store_register_submit_button_clicked = "store_register_submit_button_clicked"
  
  // delete_request_popup
  case delete_request_popup_close_button_clicked = "delete_request_popup_close_button_clicked"
  case delete_request_submit_button_clicked = "delete_request_submit_button_clicked"
  
  // my_info_page
  case setting_button_clicked = "setting_button_clicked"
  case show_all_my_store_button_clicked = "show_all_my_store_button_clicked"
  case show_all_my_review_button_clicked = "show_all_my_review_button_clicked"
  
  // setting_page
  case nickname_change_page_button_clicked = "nickname_change_page_button_clicked"
  case logout_button_clicked = "logout_button_clicked"
  case signout_button_clicked = "signout_button_clicked"
  case signout_alert_withdraw_button_clicked = "signout_alert_withdraw_button_clicked"
  case signout_alert_cancel_button_clicked = "signout_alert_cancel_button_clicked"
  case inquiry_button_clicked = "inquiry_button_clicked"
  case privacy_button_clicked = "privacy_button_clicked"
    
    // 푸드트럭 상세화면
    case view_boss_store_detail
}
