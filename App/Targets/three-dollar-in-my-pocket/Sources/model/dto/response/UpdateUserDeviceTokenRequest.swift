struct UpdateUserDeviceTokenRequest: Requestable {
    let pushPlatformType: PushPlatformType
    let pushToken: String
    
    var params: [String : Any] {
        return [
            "pushPlatformType": pushPlatformType.value,
            "pushToken": pushToken
        ]
    }
    
    init(
        pushPlatformType: PushPlatformType,
        pushToken: String
    ) {
        self.pushPlatformType = pushPlatformType
        self.pushToken = pushToken
    }
}
