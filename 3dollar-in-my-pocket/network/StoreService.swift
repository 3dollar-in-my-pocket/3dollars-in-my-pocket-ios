import Alamofire
import ObjectMapper

struct StoreService: APIServiceType {
    
    
    static func getStoreOrderByNearest(latitude: Double, longitude: Double,
                                       completion: @escaping (DataResponse<[StoreCard]>) -> Void) {
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
                completion(response)
        }
    }
    
    static func saveStore(store: Store, completion: @escaping (DataResponse<String>) -> Void) {
        let urlString = self.url("api/v1/store/save")
        let headers = self.defaultHeader()
        var parameters = store.toDict()
        parameters["userId"] = "\(UserDefaultsUtil.getUserId()!)"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
//            multipartFormData.append(UIImageJPEGRepresentation(self.photoImageView.image!, 1)!, withName: "photo_path", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: urlString, headers: headers) { (result) in
            switch result {
            case .success(let uploadRequest, _, _):
                uploadRequest.responseString(completionHandler: { (response) in
                    completion(response)
                })
            case .failure(let error):
                AlertUtils.show(title: "Save store error", message: error.localizedDescription)
            }
        }
    }
}
