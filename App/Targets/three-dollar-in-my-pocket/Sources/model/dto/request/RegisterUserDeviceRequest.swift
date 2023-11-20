struct RegisterUserDeviceRequest: Requestable {
    let pushPlatformType: PushPlatformType
    let pushToken: String
    
    var params: [String: Any] {
        return [
            "pushPlatformType": pushPlatformType.value,
            "pushToken": pushToken
        ]
    }
}
