import Foundation

struct UserActivity: Equatable {
    let medalsCounts: Int
    let reviewsCount: Int
    let storesCount: Int
    
    init() {
        self.medalsCounts = 0
        self.reviewsCount = 0
        self.storesCount = 0
    }
    
    init(response: UserWithActivityResponse.ActivityResponse) {
        self.medalsCounts = response.medalsCounts
        self.reviewsCount = response.reviewsCount
        self.storesCount = response.storesCount
    }
}
