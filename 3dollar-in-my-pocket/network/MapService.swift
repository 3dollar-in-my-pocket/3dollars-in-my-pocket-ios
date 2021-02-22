import RxSwift
import Alamofire

protocol MapServiceProtocol {
  func getAddressFromLocation(lat: Double, lng: Double) -> Observable<String>
  
  func searchAddress(keyword: String) -> Observable<LocalResponse<PlaceDocument>>
  
  func getCurrentAddress(lat: Double, lng: Double) -> Observable<LocalResponse<AddressDocument>>
}

struct MapService: MapServiceProtocol {
  
  func getAddressFromLocation(lat: Double, lng: Double) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"
      let headers: HTTPHeaders = [
        "X-NCP-APIGW-API-KEY-ID": "hqqqtcv85g",
        "X-NCP-APIGW-API-KEY": "Nk7L8VvCq9YkDuGPjvGDN8FW5ELfWTt23AgcS9ie"
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
            let address = naverMapResponse.getAddress()
            
            observer.onNext(address)
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "데이터를 파싱할 수 없습니다.")
            observer.onError(error)
          }
        }
      }
      return Disposables.create()
    }
  }
  
  func searchAddress(keyword: String) -> Observable<LocalResponse<PlaceDocument>> {
    return Observable.create { observer -> Disposable in
      let urlString = "https://dapi.kakao.com/v2/local/search/keyword.json"
      let headers: HTTPHeaders = [
        "Authorization": "KakaoAK 5bbbafb84c73c6be5b181b6f3d514129"
      ] as HTTPHeaders
      let parameters: [String: Any] = [
        "query": keyword,
        "size": 10
      ]
      
      AF.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headers
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: LocalResponse<PlaceDocument>.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
  
  func getCurrentAddress(lat: Double, lng: Double) -> Observable<LocalResponse<AddressDocument>> {
    return Observable.create { observer -> Disposable in
      let urlString = "https://dapi.kakao.com/v2/local/geo/coord2address.json"
      let headers: HTTPHeaders = [
        "Authorization": "KakaoAK 5bbbafb84c73c6be5b181b6f3d514129"
      ] as HTTPHeaders
      let parameters: [String: Any] = [
        "x": lng,
        "y": lat
      ]
      
      AF.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headers
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: LocalResponse<AddressDocument>.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
}
