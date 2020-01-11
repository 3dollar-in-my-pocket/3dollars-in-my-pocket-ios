import Alamofire
import ObjectMapper

struct StoreService: APIServiceType {
    
    
    static func getStoreOrderByNearest(latitude: Double, longitude: Double,
                                       complection: @escaping (DataResponse<[StoreCard]>) -> Void) {
        let urlString = self.url("api/v1/store/get")
        let headers = self.defaultHeader()
        let parameters = ["latitude": latitude, "longitude": longitude]
        
        Alamofire.request(urlString, method: .get, parameters: parameters, headers: headers)
            .responseJSON { (response) in
                print(response)
                let response: DataResponse<[StoreCard]> = response.flatMapResult { json in
                    
                    if let storeCards = Mapper<StoreCard>().mapArray(JSONObject: json) {
                        return .success(storeCards)
                    } else {
                        return .failure(MappingError.init(from: self, to: StoreCard.self))
                    }
                }
                complection(response)
        }
    }
}
