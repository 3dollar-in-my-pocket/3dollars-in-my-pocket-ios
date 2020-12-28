enum GAEvent: String {
  // Login_page
  case login_kakao_login_button_clicked = "login_kakao_login_button_clicked"
  case login_apple_login_button_clicked = "login_apple_login_button_clicked"
  
  // Nickname_initilize_page
  case nickname_initilize_back_button_clicked = "nickname_initilize_back_button_clicked"
  case nickname_initilize_change_button_clicked = "nickname_initilize_change_button_clicked"
  case nickname_initilize_already_existed = "nickname_initilize_already_existed"
  
  // Nickname_change_page
  case nickname_change_back_button_clicked = "nickname_change_back_button_clicked"
  case nickname_change_change_button_clicked = "nickname_change_change_button_clicked"
  case back_button_clicked = "back_button_clicked"
  case nickname_change_already_existed = "nickname_change_already_existed"
  
  // Home_page
  case home_filter_bungeoppang_button_clicked = "home_filter_bungeoppang_button_clicked"
  case home_filter_takoyaki_button_clicked = "home_filter_takoyaki_button_clicked"
  case home_filter_gyeranppang_button_clicked = "home_filter_gaeranppang_button_clicked"
  case home_filter_hotteok_button_clicked = "home_filter_hotteok_button_clicked"
  case home_store_card_button_clicked = "home_store_card_button_clicked"
  case home_store_card_swiped = "home_store_card_swiped"
}
