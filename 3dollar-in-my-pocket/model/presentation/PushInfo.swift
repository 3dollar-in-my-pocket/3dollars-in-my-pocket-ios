struct PushInfo: Equatable {
    var isPushEnable: Bool
    
    init(response: DeviceInfoResponse) {
        self.isPushEnable = response.isSetupNotification
    }
    
    init(isPushEnable: Bool = false) {
        self.isPushEnable = isPushEnable
    }
}
