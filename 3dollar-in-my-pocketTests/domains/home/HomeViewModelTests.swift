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
import CoreLocation

class HomeViewModelSpec: QuickSpec {
  override func spec() {
    describe("홈 화면") {
      var disposeBag: DisposeBag!
      var schedular: TestScheduler!
      var userDefaults: UserDefaultsUtil!
      var storeService: StoreServiceMock!
      var mapService: MapServiceMock!
      var viewModel: HomeViewModel!
      var storeMock: StoreMock!
      
      beforeEach {
        disposeBag = DisposeBag()
        schedular = TestScheduler(initialClock: 0)
        userDefaults = UserDefaultsUtil(name: #file)
        storeMock = StoreMock()
      }
      
      context("화면 첫 로딩") {
        beforeEach {
          storeService.searchNearStoresObservable = .create { observer in
            observer.onNext(storeMock.fetchHomeStores())
            observer.onCompleted()
            
            return Disposables.create()
          }
          viewModel = HomeViewModel(
            storeService: storeService,
            mapService: mapService,
            userDefaults: userDefaults
          )
        }
        
        it("로딩창이 켜졌다가 꺼지는가?") {
          schedular.createColdObservable([.next(210, CLLocation(latitude: 0, longitude: 0))])
            .bind(to: viewModel.input.currentLocation)
            .disposed(by: disposeBag)
          
          expect(viewModel.showLoading)
            .events(scheduler: schedular, disposeBag: disposeBag)
            .to(equal([
              .next(210, true),
              .next(220, false)
            ]), description: "로딩창이 켜졌다가 꺼지지 않았습니다.")
          schedular.start()
        }
      }
    }
  }
}
