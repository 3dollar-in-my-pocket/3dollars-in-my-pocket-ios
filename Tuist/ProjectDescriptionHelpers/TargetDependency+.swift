import ProjectDescription

public extension TargetDependency {
    static let mock = TargetDependency.project(
        target: "Mock",
        path: .relativeToRoot("./Modules/Mock")
    )
    
    class Core {
        public static let dependencyInjection = TargetDependency.project(
            target: "DependencyInjection",
            path: .relativeToRoot("./Modules/Core/DependencyInjection")
        )
        
        public static let networking = TargetDependency.project(
            target: "Networking",
            path: .relativeToRoot("./Modules/Core/Network")
        )
        
        public static let common = TargetDependency.project(
            target: "Common",
            path: .relativeToRoot("./Modules/Core/Common")
        )
        
        public static let model = TargetDependency.project(
            target: "Model",
            path: .relativeToRoot("./Modules/Core/Model")
        )
        
        public static let log = TargetDependency.project(
            target: "Log",
            path: .relativeToRoot("./Modules/Core/Log")
        )
        
        public static let resource = TargetDependency.project(
            target: "Resource",
            path: .relativeToRoot("./Modules/Core/Resource")
        )
        
        public static let designSystem = TargetDependency.project(
            target: "DesignSystem",
            path: .relativeToRoot("./Modules/Core/DesignSystem")
        )
    }
    
    class Feature {
        public static let home = TargetDependency.project(
            target: "Home",
            path: .relativeToRoot("./Modules/Feature/Home")
        )
        
        public static let community = TargetDependency.project(
            target: "Community",
            path: .relativeToRoot("./Modules/Feature/Community")
        )
        
        public static let membership = TargetDependency.project(
            target: "Membership",
            path: .relativeToRoot("./Modules/Feature/Membership")
        )
        
        public static let store = TargetDependency.project(
            target: "Store",
            path: .relativeToRoot("./Modules/Feature/Store")
        )
        
        public static let write = TargetDependency.project(
            target: "Write",
            path: .relativeToRoot("./Modules/Feature/Write")
        )
    }
    
    class Interface {
        public static let appInterface = TargetDependency.project(
            target: "AppInterface",
            path: .relativeToRoot("./App")
        )
        
        public static let communityInterface = TargetDependency.project(
            target: "CommunityInterface",
            path: .relativeToRoot("./Modules/Feature/Community")
        )
        
        public static let membershipInterface = TargetDependency.project(
            target: "MembershipInterface",
            path: .relativeToRoot("./Modules/Feature/Membership")
        )
        
        public static let storeInterface = TargetDependency.project(
            target: "StoreInterface",
            path: .relativeToRoot("./Modules/Feature/Store")
        )
        
        public static let writeInterface = TargetDependency.project(
            target: "WriteInterface",
            path: .relativeToRoot("./Modules/Feature/Write")
        )
    }
    
    class SPM {
        public static let lottie = TargetDependency.external(name: "Lottie")
        public static let swinject = TargetDependency.external(name: "Swinject")
        public static let kingfisher = TargetDependency.external(name: "Kingfisher")
        public static let snapKit = TargetDependency.external(name: "SnapKit")
        public static let then = TargetDependency.external(name: "Then")
        public static let panModal = TargetDependency.external(name: "PanModal")
    }
}
