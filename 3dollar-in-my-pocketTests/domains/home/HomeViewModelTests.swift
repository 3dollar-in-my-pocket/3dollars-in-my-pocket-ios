//
//  HomeViewModelTests.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/09/25.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Quick
import Nimble
import RxNimble
import RxSwift
import RxTest

@testable import dollar_in_my_pocket

class HomeViewModelSpec: QuickSpec {
  override func spec() {
    describe("내 위치 가져오기") {
      var disposeBag: DisposeBag!
      let schedular = TestScheduler(initialClock: 0)
      
      beforeEach {
        disposeBag = DisposeBag()
      }
      
      it("테스트용 테스트") {
        let homeViewModel = HomeViewModel(
          storeService: StoreService(),
          mapService: MapService(),
          userDefaults: UserDefaultsUtil()
        )
        
        schedular.createColdObservable([.next(210, true)])
          .bind(to: homeViewModel.output.isHiddenResearchButton)
          .disposed(by: disposeBag)
        
        expect(homeViewModel.output.isHiddenResearchButton)
          .events(scheduler: schedular, disposeBag: disposeBag)
          .to(equal([
            Recorded.next(210, true)
          ]), description: "isHiddenResearchButton 여기를 확인하셔요!")
        schedular.start()
      }
    }
  }
}
