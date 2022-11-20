struct DeviceInfoResponse: Decodable {
    let isSetupNotification: Bool
    let pushSettings: [String]
    
    enum CodingKeys: String, CodingKey {
        case isSetupNotification
        case pushSettings
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.isSetupNotification = try values.decodeIfPresent(
            Bool.self,
            forKey: .isSetupNotification
        ) ?? false
        self.pushSettings = try values.decodeIfPresent(
            [String].self,
            forKey: .pushSettings
        ) ?? []
    }
    
    init(
        isSetupNotification: Bool = false,
        pushSettings: [String] = []
    ) {
        self.isSetupNotification = isSetupNotification
        self.pushSettings = pushSettings
    }
}
