//
//  MyPageCoordinator.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/08/26.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

protocol MyPageCoordinator: BaseCoordinator, AnyObject {
    func goToSetting()
    
    func goToMyMedal(medal: Medal)
    
    func goToTotalRegisteredStore()
    
    func goToMyReview()
    
    func goToStoreDetail(storeId: Int)
    
    func goToMyVisitHistory()
    
    func pushBookmarkList(userName: String)
}

extension MyPageCoordinator {
    func goToSetting() {
        let viewController = SettingViewController.instance()
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToMyMedal(medal: Medal) {
        let viewController = MyMedalViewController.instance(medal: medal)
        
        viewController.delegate = self as? MyMedalViewControllerDelegate
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToTotalRegisteredStore() {
        let viewController = RegisteredStoreViewController.instance()
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToMyReview() {
        let viewController = MyReviewViewController.instance()
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToStoreDetail(storeId: Int) {
        let viewController = StoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToMyVisitHistory() {
        let viewController = MyVisitHistoryViewController.instance()
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func pushBookmarkList(userName: String) {
        let viewController = BookmarkListViewController.instance(userName: userName)
        
        self.presenter.navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
}
