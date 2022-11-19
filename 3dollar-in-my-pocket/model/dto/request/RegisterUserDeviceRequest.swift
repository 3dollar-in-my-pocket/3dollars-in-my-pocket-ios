struct RegisterUserDeviceRequest: Requestable {
    let pushPlatformType: PushPlatformType
    let pushSettings: [PushSettingType]
    let pushToken: String
    
    var params: [String : Any] {
        return [
            "pushPlatformType" : pushPlatformType.value,
            "pushSettings": pushSettings.map { $0.value },
            "pushToken": pushToken
        ]
    }
}
