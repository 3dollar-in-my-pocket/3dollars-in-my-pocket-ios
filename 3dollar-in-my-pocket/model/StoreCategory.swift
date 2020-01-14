public enum StoreCategory: String {
    case BUNGEOPPANG = "BUNGEOPPANG"
    case TAKOYAKI = "TAKOYAKI"
    case GYERANPPANG = "GYERANPPANG"
    case HOTTEOK = "HOTTEOK"
    
    func getValue() -> String {
        return self.rawValue
    }
}
