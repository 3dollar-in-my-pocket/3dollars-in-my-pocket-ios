import Foundation

struct CategoryChildViewModel {
  
  var storeByDistance: CategoryByDistance = CategoryByDistance.init()
  var storeByReview: CategoryByReview = CategoryByReview.init()
  
  
  mutating func setDistance(storeByDistance: CategoryByDistance) {
    self.storeByDistance = storeByDistance
    if !storeByDistance.storeList50.isEmpty {
      self.storeByDistance.indexList.append(0)
    }
    if !storeByDistance.storeList100.isEmpty {
      self.storeByDistance.indexList.append(1)
    }
    if !storeByDistance.storeList500.isEmpty {
      self.storeByDistance.indexList.append(2)
    }
    if !storeByDistance.storeList1000.isEmpty {
      self.storeByDistance.indexList.append(3)
    }
    if !storeByDistance.storeListOver1000.isEmpty {
      self.storeByDistance.indexList.append(4)
    }
  }
  
  mutating func setReview(storeByReview: CategoryByReview) {
    self.storeByReview = storeByReview
    
    if !storeByReview.storeList4.isEmpty {
      self.storeByReview.indexList.append(0)
    }
    if !storeByReview.storeList3.isEmpty {
      self.storeByReview.indexList.append(1)
    }
    if !storeByReview.storeList2.isEmpty {
      self.storeByReview.indexList.append(2)
    }
    if !storeByReview.storeList1.isEmpty {
      self.storeByReview.indexList.append(3)
    }
    if !storeByReview.storeList0.isEmpty {
      self.storeByReview.indexList.append(4)
    }
  }
  
  func getAllDistanceStores() -> [StoreCard] {
    var result: [StoreCard] = []
    
    result.append(contentsOf: storeByDistance.storeList50)
    result.append(contentsOf: storeByDistance.storeList100)
    result.append(contentsOf: storeByDistance.storeList500)
    result.append(contentsOf: storeByDistance.storeList1000)
    result.append(contentsOf: storeByDistance.storeListOver1000)
    return result
  }
  
  func getAllReviewStores() -> [StoreCard] {
    var result: [StoreCard] = []
    
    result.append(contentsOf: storeByReview.storeList0)
    result.append(contentsOf: storeByReview.storeList1)
    result.append(contentsOf: storeByReview.storeList2)
    result.append(contentsOf: storeByReview.storeList3)
    result.append(contentsOf: storeByReview.storeList4)
    return result
  }
  
  func isDistanceEmpty() -> Bool {
    return storeByDistance.storeList50.isEmpty && storeByDistance.storeList100.isEmpty &&
      storeByDistance.storeList500.isEmpty && storeByDistance.storeList1000.isEmpty &&
      storeByDistance.storeListOver1000.isEmpty
  }
  
  func isReviewEmpty() -> Bool {
    return storeByReview.storeList0.isEmpty && storeByReview.storeList1.isEmpty &&
      storeByReview.storeList2.isEmpty && storeByReview.storeList3.isEmpty &&
      storeByReview.storeList4.isEmpty
  }
  
  func getNumberOfDistanceRow(section: Int) -> Int {
    switch self.storeByDistance.indexList[section] {
    case 0:
      return storeByDistance.storeList50.count
    case 1:
      return storeByDistance.storeList100.count
    case 2:
      return storeByDistance.storeList500.count
    case 3:
      return storeByDistance.storeList1000.count
    case 4:
      return storeByDistance.storeListOver1000.count
    default:
      return 0
    }
  }
  
  func getNumberOfReviewRow(section: Int) -> Int {
    switch self.storeByReview.indexList[section] {
    case 0:
      return storeByReview.storeList4.count
    case 1:
      return storeByReview.storeList3.count
    case 2:
      return storeByReview.storeList2.count
    case 3:
      return storeByReview.storeList1.count
    case 4:
      return storeByReview.storeList0.count
    default:
      return 0
    }
  }
  
  func getDistanceStore(indexPath: IndexPath) -> StoreCard? {
    switch self.storeByDistance.indexList[indexPath.section] {
    case 0:
      return self.storeByDistance.storeList50[indexPath.row]
    case 1:
      return self.storeByDistance.storeList100[indexPath.row]
    case 2:
      return self.storeByDistance.storeList500[indexPath.row]
    case 3:
      return self.storeByDistance.storeList1000[indexPath.row]
    case 4:
      return self.storeByDistance.storeListOver1000[indexPath.row]
    default:
      return nil
    }
  }
  
  func getReviewStore(indexPath: IndexPath) -> StoreCard? {
    switch self.storeByReview.indexList[indexPath.section] {
    case 0:
      return self.storeByReview.storeList4[indexPath.row]
    case 1:
      return self.storeByReview.storeList3[indexPath.row]
    case 2:
      return self.storeByReview.storeList2[indexPath.row]
    case 3:
      return self.storeByReview.storeList1[indexPath.row]
    case 4:
      return self.storeByReview.storeList0[indexPath.row]
    default:
      return nil
    }
  }
  
  func isValidDistanceSection(section: Int) -> Bool {
    switch self.storeByDistance.indexList[section] {
    case 0:
      return !storeByDistance.storeList50.isEmpty
    case 1:
      return !storeByDistance.storeList100.isEmpty
    case 2:
      return !storeByDistance.storeList500.isEmpty
    case 3:
      return !storeByDistance.storeList1000.isEmpty
    case 4:
      return !storeByDistance.storeListOver1000.isEmpty
    default:
      return false
    }
  }
  
  func isValidReviewSection(section: Int) -> Bool {
    switch self.storeByReview.indexList[section] {
    case 0:
      return !storeByReview.storeList4.isEmpty
    case 1:
      return !storeByReview.storeList3.isEmpty
    case 2:
      return !storeByReview.storeList2.isEmpty
    case 3:
      return !storeByReview.storeList1.isEmpty
    case 4:
      return !storeByReview.storeList0.isEmpty
    default:
      return false
    }
  }
  
  func getValidDistanceCount() -> Int {
    var sectionCount = 0
    
    if !storeByDistance.storeList50.isEmpty {
      sectionCount += 1
    }
    if !storeByDistance.storeList100.isEmpty {
      sectionCount += 1
    }
    if !storeByDistance.storeList500.isEmpty {
      sectionCount += 1
    }
    if !storeByDistance.storeList1000.isEmpty {
      sectionCount += 1
    }
    if !storeByDistance.storeListOver1000.isEmpty {
      sectionCount += 1
    }
    return sectionCount
  }
  
  func getValidReviewCount() -> Int {
    var sectionCount = 0
    
    if !storeByReview.storeList4.isEmpty {
      sectionCount += 1
    }
    if !storeByReview.storeList3.isEmpty {
      sectionCount += 1
    }
    if !storeByReview.storeList2.isEmpty {
      sectionCount += 1
    }
    if !storeByReview.storeList1.isEmpty {
      sectionCount += 1
    }
    if !storeByReview.storeList0.isEmpty {
      sectionCount += 1
    }
    return sectionCount
  }
}
