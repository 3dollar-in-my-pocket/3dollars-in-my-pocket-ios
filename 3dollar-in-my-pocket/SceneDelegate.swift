//
//  SceneDelegate.swift
//  3dollar-in-my-pocket
//
//  Created by Hyunsik Yoo on 2019/12/19.
//  Copyright © 2019 Macgongmon. All rights reserved.
//

import UIKit
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(frame: windowScene.coordinateSpace.bounds)
    window?.windowScene = windowScene
    window?.backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
    window?.rootViewController = SplashVC.instance()
    window?.makeKeyAndVisible()
  }
  
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if let url = URLContexts.first?.url {
      if (AuthApi.isKakaoTalkLoginUrl(url)) {
        _ = AuthController.handleOpenUrl(url: url)
      }
    }
  }
  
  func goToMain() {
    window?.rootViewController = MainVC.instance()
    window?.makeKeyAndVisible()
  }
  
  func goToSignIn() {
    window?.rootViewController = SignInVC.instance()
    window?.makeKeyAndVisible()
  }
  
}

