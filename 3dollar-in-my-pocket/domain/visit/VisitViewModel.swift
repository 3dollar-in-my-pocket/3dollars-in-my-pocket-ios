//
//  VisitViewModel.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/09.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import RxSwift
import RxCocoa
import CoreLocation

final class VisitViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  var model: Model
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let tapCurrentLocationButton = PublishSubject<Void>()
    let tapVisitButton = PublishSubject<VisitType>()
  }
  
  struct Output {
    let store = PublishRelay<Store>()
    let distance = PublishRelay<Int>()
    let currentLocation = PublishRelay<(Double, Double)>()
    let isVisitable = PublishRelay<Bool>()
    let moveCamera = PublishRelay<(Double, Double)>()
    let dismiss = PublishRelay<Store>()
  }
  
  struct Model {
    var store: Store
    var currentLocation: (Double, Double)?
    let visitMaxRange = 100
  }
    
  private let locationManager: LocationManagerProtocol
  private let visitHistoryService: VisitHistoryServiceProtocol
  
  init(
    store: Store,
    locationManager: LocationManagerProtocol,
    visitHistoryService: VisitHistoryServiceProtocol
  ) {
    self.model = Model(store: store)
    self.locationManager = locationManager
    self.visitHistoryService = visitHistoryService
    
    super.init()
  }
  
  override func bind() {
    self.input.viewDidLoad
      .compactMap { [weak self] in
        self?.model.store
      }
      .do(onNext: { [weak self] _ in
        self?.trackingLocation()
      })
      .bind(to: self.output.store)
      .disposed(by: self.disposeBag)
    
    self.input.tapCurrentLocationButton
      .compactMap { [weak self] in
        self?.model.currentLocation
      }
      .bind(to: self.output.moveCamera)
      .disposed(by: self.disposeBag)
    
    self.input.tapVisitButton
      .bind { [weak self] type in
        self?.visitStore(type: type)
      }
      .disposed(by: self.disposeBag)
  }
  
  private func trackingLocation() {
    Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance)
      .startWith(0)
      .flatMap { _ -> Observable<CLLocation> in
        return self.locationManager.getCurrentLocation()
      }
      .bind { [weak self] location in
        guard let self = self else { return }
        let storePosition = CLLocation(
          latitude: self.model.store.latitude,
          longitude: self.model.store.longitude
        )
        let distnace = Int(location.distance(from: storePosition))

        self.model.currentLocation = (location.coordinate.latitude, location.coordinate.longitude)
        self.output.currentLocation.accept((location.coordinate.latitude, location.coordinate.longitude))
        self.output.distance.accept(distnace - self.model.visitMaxRange)
        self.output.isVisitable.accept(distnace < self.model.visitMaxRange)
      }
      .disposed(by: self.disposeBag)
  }
  
  private func visitStore(type: VisitType) {
    self.visitHistoryService.visitStore(
      storeId: self.model.store.storeId,
      type: type
    ).subscribe { [weak self] _ in
      guard let self = self else { return }
      
      self.updateCertificate(type: type)
      self.output.dismiss.accept(self.model.store)
    } onError: { [weak self] error in
      self?.showErrorAlert.accept(error)
    }
    .disposed(by: self.disposeBag)
  }
  
  private func updateCertificate(type: VisitType) {
    switch type {
    case .exists:
      self.model.store.visitHistory.existsCounts += 1
      
    case .notExists:
      self.model.store.visitHistory.notExistsCounts += 1
    }
    
    self.model.store.visitHistory.isCertified
      = self.model.store.visitHistory.existsCounts > self.model.store.visitHistory.notExistsCounts
  }
}
