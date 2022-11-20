import RxSwift
import FirebaseMessaging

protocol DeviceServiceProtocol {
    func registerDevice(
        pushPlatformType: PushPlatformType,
        pushToken: String
    ) -> Observable<String>
    
    func deleteDevice() -> Observable<Void>
    
    func refreshDeivce(
        pushPlatformType: PushPlatformType,
        pushToken: String
    ) -> Observable<String>
    
    func getFCMToken() -> Observable<String>
}

struct DeviceService: DeviceServiceProtocol {
    private let networkManager = NetworkManager()
    
    func registerDevice(
        pushPlatformType: PushPlatformType,
        pushToken: String
    ) -> Observable<String> {
        let urlString = HTTPUtils.url + "/api/v1/device"
        let headers = HTTPUtils.defaultHeader()
        let registerUserDeviceRequest = RegisterUserDeviceRequest(
            pushPlatformType: pushPlatformType,
            pushToken: pushToken
        )
        
        return self.networkManager.createPostObservable(
            class: String.self,
            urlString: urlString,
            headers: headers,
            parameters: registerUserDeviceRequest.params
        )
    }
    
    func deleteDevice() -> Observable<Void> {
        let urlString = HTTPUtils.url + "/api/v1/device"
        let headers = HTTPUtils.defaultHeader()
        
        return self.networkManager.createDeleteObservable(
            urlString: urlString,
            headers: headers
        )
    }
    
    func refreshDeivce(
        pushPlatformType: PushPlatformType,
        pushToken: String
    ) -> Observable<String> {
        let urlString = HTTPUtils.url + "/api/v1/device"
        let headers = HTTPUtils.defaultHeader()
        let updateUserDeviceTokenRequest = UpdateUserDeviceTokenRequest(
            pushPlatformType: pushPlatformType,
            pushToken: pushToken
        )
        
        return self.networkManager.createPutObservable(
            class: String.self,
            urlString: urlString,
            headers: headers,
            parameters: updateUserDeviceTokenRequest.params
        )
    }
    
    func getFCMToken() -> Observable<String> {
        return .create { observer in
            Messaging.messaging().token { token, error in
                if let error = error {
                    observer.onError(error)
                } else if let token = token {
                    observer.onNext(token)
                    observer.onCompleted()
                } else {
                    observer.onError(BaseError.unknown)
                }
            }
            
            return Disposables.create()
        }
    }
}
