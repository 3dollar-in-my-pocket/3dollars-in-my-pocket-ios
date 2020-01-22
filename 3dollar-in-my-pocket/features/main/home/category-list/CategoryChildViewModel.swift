import Foundation

struct CategoryChildViewModel {
    var storeByDistance: CategoryByDistance = CategoryByDistance.init()
    var storeByReview: CategoryByReview = CategoryByReview.init()
    
    func getAllDistanceStores() -> [StoreCard] {
        var result: [StoreCard] = []
        
        result.append(contentsOf: storeByDistance.storeList50)
        result.append(contentsOf: storeByDistance.storeList100)
        result.append(contentsOf: storeByDistance.storeList500)
        result.append(contentsOf: storeByDistance.storeList1000)
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
    
    func getNumberOfDistanceRow(section: Int) -> Int {
        switch getRealDistanceSection(section: section) {
        case 0:
            return storeByDistance.storeList50.count
        case 1:
            return storeByDistance.storeList100.count
        case 2:
            return storeByDistance.storeList500.count
        case 3:
            return storeByDistance.storeList1000.count
        default:
            return 0
        }
    }
    
    func getNumberOfReviewRow(section: Int) -> Int {
        switch getRealReviewSection(section: section) {
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
        switch getRealDistanceSection(section: indexPath.section) {
        case 0:
            return self.storeByDistance.storeList50[indexPath.row]
        case 1:
            return self.storeByDistance.storeList100[indexPath.row]
        case 2:
            return self.storeByDistance.storeList500[indexPath.row]
        case 3:
            return self.storeByDistance.storeList1000[indexPath.row]
        default:
            return nil
        }
    }
    
    func getReviewStore(indexPath: IndexPath) -> StoreCard? {
        switch getRealReviewSection(section: indexPath.section) {
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
        switch getRealDistanceSection(section: section) {
        case 0:
            return !storeByDistance.storeList50.isEmpty
        case 1:
            return !storeByDistance.storeList100.isEmpty
        case 2:
            return !storeByDistance.storeList500.isEmpty
        case 3:
            return !storeByDistance.storeList1000.isEmpty
        default:
            return false
        }
    }
    
    func isValidReviewSection(section: Int) -> Bool {
        switch getRealReviewSection(section: section) {
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
    
    func getRealDistanceSection(section: Int) -> Int {
        var result = section
        
        switch section {
        case 0:
            if storeByDistance.storeList50.isEmpty {
                result += 1
                if storeByDistance.storeList100.isEmpty {
                    result += 1
                    if storeByDistance.storeList500.isEmpty {
                        result += 1
                    } else {
                        return result
                    }
                } else {
                    return section
                }
            } else {
                return section
            }
        case 1:
            if storeByDistance.storeList100.isEmpty {
                result += 1
                if storeByDistance.storeList500.isEmpty {
                    result += 1
                } else {
                    return result
                }
            } else {
                return result
            }
        case 2:
            if storeByDistance.storeList500.isEmpty {
                result += 1
            }
        default:
            break
        }
        return result
    }
    
    func getRealReviewSection(section: Int) -> Int {
        var result = section
        
        switch section {
        case 0:
            if storeByReview.storeList4.isEmpty {
                result += 1
                if storeByReview.storeList3.isEmpty {
                    result += 1
                    if storeByReview.storeList2.isEmpty {
                        result += 1
                        if storeByReview.storeList1.isEmpty {
                            result += 1
                        }
                    }
                }
            }
        case 1:
            if storeByReview.storeList3.isEmpty {
                result += 1
                if storeByReview.storeList2.isEmpty {
                    result += 1
                    if storeByReview.storeList1.isEmpty {
                        result += 1
                    }
                }
            }
        case 2:
            if storeByReview.storeList2.isEmpty {
                result += 1
                if storeByReview.storeList1.isEmpty {
                    result += 1
                }
            }
        case 3:
            if storeByReview.storeList1.isEmpty {
                result += 1
            }
        default:
            break
        }
        return result
    }
}
