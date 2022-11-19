struct PushInfo {
    var isPushEnable: Bool
    var pushSetting: [PushSettingType]
    
    init(response: DeviceInfoResponse) {
        self.isPushEnable = response.isSetupNotification
        self.pushSetting = response.pushSettings.map { PushSettingType.init(value: $0) }
    }
    
    init(
        isPushEnable: Bool = false,
        pushSetting: [PushSettingType] = []
    ) {
        self.isPushEnable = isPushEnable
        self.pushSetting = pushSetting
    }
}
