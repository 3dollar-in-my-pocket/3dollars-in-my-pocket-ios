import RxSwift
import Alamofire

protocol MapServiceProtocol {
  func getAddressFromLocation(lat: Double, lng: Double) -> Observable<String>
}

struct MapService: MapServiceProtocol {
  func getAddressFromLocation(lat: Double, lng: Double) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"
      let headers: HTTPHeaders = [
        "X-NCP-APIGW-API-KEY-ID": "b7agu1h5c2",
        "X-NCP-APIGW-API-KEY": "XXQown7wQLSB7oa5aHR21nJLyEHF2RK9kYe8Zcmt"
      ] as HTTPHeaders
      let parameters: [String: Any] = [
        "request": "coordsToaddr",
        "coords": "\(lng),\(lat)",
        "orders": "legalcode,admcode,addr,roadaddr",
        "output": "json"
      ]
      
      AF.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headers
      ).responseJSON { (response) in
        if let value = response.value {
          if let naverMapResponse: NaverMapResponse = JsonUtils.toJson(object: value) {
            Log.debug(naverMapResponse)
          }
        }
        
//        let decoder = JSONDecoder()
//        if let data = response.data,
//           let geoLocation = try? decoder.decode(NaverMapResponse.self, from: data) {
//
//          if !geoLocation.results.isEmpty {
//            var address = "\(geoLocation.results[0].region.area1.name!) \(geoLocation.results[0].region.area2.name!) \(geoLocation.results[0].region.area3.name!) \(geoLocation.results[0].region.area4.name!)"
//
//            if geoLocation.results.count == 4 {
//              if let name = geoLocation.results[3].land?.name {
//                address = "\(address) \(name)"
//              }
//
//              if let roadNumber1 = geoLocation.results[3].land?.number1 {
//                address = "\(address) \(roadNumber1)"
//              }
//
//              if let roadNumber2 = geoLocation.results[3].land?.number2,
//                 !roadNumber2.isEmpty {
//                address = "\(address)-\(roadNumber2)"
//              }
//            } else {
//              if let detail1 = geoLocation.results[2].land?.number1 {
//                address = "\(address) \(detail1)"
//              }
//
//              if let detail2 = geoLocation.results[2].land?.number2 {
//                address = "\(address)-\(detail2)"
//              }
//            }
//            completion(address)
//          }
//        } else {
//          AlertUtil.show("error", message: "주소 가져오기는 도중 에러가 발생했습니다.\n잠시후 다시 시도해주세요.")
//        }
      }
      return Disposables.create()
    }
  }
}
