enum GAEvent: String {
  
  case navigate_back_button_clicked = "navigate_back_button_clicked"
  
  case kakao_login_button_clicked = "kakao_login_button_clicked"
  case apple_login_button_clicked = "apple_login_button_clicked"
  
  case nickname_change_button_clicked = "nickname_change_button_clicked"
  case nickname_already_existed = "nickname_already_existed"
  
  case filter_bungeoppang_button_clicked = "filter_bungeoppang_button_clicked"
  case filter_takoyaki_button_clicked = "filter_takoyaki_button_clicked"
  case filter_gyeranppang_button_clicked = "filter_gaeranppang_button_clicked"
  case filter_hotteok_button_clicked = "filter_hotteok_button_clicked"
  case store_card_button_clicked = "store_card_button_clicked"
  case store_card_swiped = "store_card_swiped"
  
  
  case navigation_home_button_clicked = "navigation_home_button_clicked"
  case navigation_register_button_clicked = "navigation_register_button_clicked"
  case navigation_my_page_button_clicked = "navigation_my_page_button_clicked"
  
  case order_by_distance_button_list = "order_by_distance_button_list"
  case order_by_rating_button_list = "order_by_rating_button_list"
  
  case store_list_item_clicked = "store_list_item_clicked"
  
  case review_write_button_clicked = "review_write_button_clicked"
  case store_modify_button_clicked = "store_modify_button_clicked"
  case share_button_clicked = "share_button_clicked"
  
  case review_write_close_button_clicked = "review_write_close_button_clicked"
  case star_button_clicked = "star_button_clicked"
  case review_register_button_clicked = "review_register_button_clicked"
  
  case close_button_clicked = "close_button_clicked"
  case store_category_button_clicked = "store_category_button_clicked"
  case image_attach_button_clicked = "image_attach_button_clicked"
  case store_register_submit_button_clicked = "store_register_submit_button_clicked"
  
  case store_edit_submit_button_clicked = "store_edit_submit_button_clicked"
  case delete_request_button_clicked = "delete_request_button_clicked"
  case delete_request_popup_close_button_clicked = "delete_request_popup_close_button_clicked"
  case delete_request_submit_button_clicked = "delete_request_submit_button_clicked"
  
  case setting_button_clicked = "setting_button_clicked"
  case show_all_my_store_button_clicked = "show_all_my_store_button_clicked"
  case show_all_my_review_button_clicked = "show_all_my_review_button_clicked"
  
  case nickname_change_page_button_clicked = "nickname_change_page_button_clicked"
  case logout_button_clicked = "logout_button_clicked"
  case signout_button_clicked = "signout_button_clicked"
  case signout_alert_withdraw_button_clicked = "signout_alert_withdraw_button_clicked"
  case signout_alert_cancel_button_clicked = "signout_alert_cancel_button_clicked"
  case inquiry_button_clicked = "inquiry_button_clicked"
  case terms_of_use_button_clicked = "terms_of_use_button_clicked"
}
