import ProjectDescription
import ProjectDescriptionHelpers

struct BuildSetting {
    struct Project {
        static let base: SettingsDictionary = [
            "ALWAYS_SEARCH_USER_PATHS": "NO",
            "CLANG_ANALYZER_NONNULL": "YES",
            "CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION": "YES_AGGRESSIVE",
            "CLANG_CXX_LANGUAGE_STANDARD": "gnu++14",
            "CLANG_CXX_LIBRARY": "libc++",
            "CLANG_ENABLE_MODULES": "YES",
            "CLANG_ENABLE_OBJC_ARC": "YES",
            "CLANG_ENABLE_OBJC_WEAK": "YES",
            "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": "YES",
            "CLANG_WARN_BOOL_CONVERSION": "YES",
            "CLANG_WARN_COMMA": "YES",
            "CLANG_WARN_CONSTANT_CONVERSION": "YES",
            "CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS": "YES",
            "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": "YES_ERROR",
            "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES",
            "CLANG_WARN_EMPTY_BODY": "YES",
            "CLANG_WARN_ENUM_CONVERSION": "YES",
            "CLANG_WARN_INFINITE_RECURSION": "YES",
            "CLANG_WARN_INT_CONVERSION": "YES",
            "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": "YES",
            "CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF": "YES",
            "CLANG_WARN_OBJC_LITERAL_CONVERSION": "YES",
            "CLANG_WARN_OBJC_ROOT_CLASS": "YES_ERROR",
            "CLANG_WARN_RANGE_LOOP_ANALYSIS": "YES",
            "CLANG_WARN_STRICT_PROTOTYPES": "YES",
            "CLANG_WARN_SUSPICIOUS_MOVE": "YES",
            "CLANG_WARN_UNGUARDED_AVAILABILITY": "YES_AGGRESSIVE",
            "CLANG_WARN_UNREACHABLE_CODE": "YES",
            "CLANG_WARN__DUPLICATE_METHOD_MATCH": "YES",
            "COPY_PHASE_STRIP": "NO",
            "ENABLE_STRICT_OBJC_MSGSEND": "YES",
            "GCC_C_LANGUAGE_STANDARD": "gnu11",
            "GCC_NO_COMMON_BLOCKS": "YES",
            "GCC_WARN_64_TO_32_BIT_CONVERSION": "YES",
            "GCC_WARN_ABOUT_RETURN_TYPE": "YES_ERROR",
            "GCC_WARN_UNDECLARED_SELECTOR": "YES",
            "GCC_WARN_UNINITIALIZED_AUTOS": "YES_AGGRESSIVE",
            "GCC_WARN_UNUSED_FUNCTION": "YES",
            "GCC_WARN_UNUSED_VARIABLE": "YES",
            "IPHONEOS_DEPLOYMENT_TARGET": "18.0",
            "MTL_FAST_MATH": "YES",
            "SDKROOT": "iphoneos",
        ]
        
        static let debug: SettingsDictionary = [
            "DEBUG_INFORMATION_FORMAT": "dwarf",
            "ENABLE_TESTABILITY": "YES",
            "GCC_DYNAMIC_NO_PIC" :"NO",
            "GCC_OPTIMIZATION_LEVEL": "0",
            "GCC_PREPROCESSOR_DEFINITIONS": "DEBUG=1 $(inherited)",
            "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
            "ONLY_ACTIVE_ARCH": "YES",
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
            "SWIFT_OPTIMIZATION_LEVEL": "-Onone"
        ]
        
        static let release: SettingsDictionary = [
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
            "ENABLE_NS_ASSERTIONS": "NO",
            "MTL_ENABLE_DEBUG_INFO": "NO",
            "SWIFT_COMPILATION_MODE": "wholemodule",
            "SWIFT_OPTIMIZATION_LEVEL": "-O",
            "VALIDATE_PRODUCT": "YES"
        ]
    }
    
    struct App {
        static let base: SettingsDictionary = [
            "MARKETING_VERSION": DefaultSetting.appVersion,
            "CURRENT_PROJECT_VERSION": DefaultSetting.buildNumber,
            "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES": "YES",
            "APPSTORE_ID": "1496099467",
            "CODE_SIGN_IDENTITY": "Apple Development",
            "CODE_SIGN_IDENTITY[sdk=iphoneos*]": "iPhone Developer",
            "CODE_SIGN_STYLE": "Manual",
            "DEVELOPMENT_TEAM": "",
            "DEVELOPMENT_TEAM[sdk=iphoneos*]": "X975A2HM62",
            "DYNAMICLINK_HOST": "https://link.threedollars.co.kr",
            "ENABLE_BITCODE": "NO",
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "SWIFT_VERSION": "5.0",
            "TARGETED_DEVICE_FAMILY": "1",
            "URL_MARKETING": "https://massive-iguana-121.notion.site/3-91156528267e426b9609d3ed57acb27d",
            "URL_POLICY": "https://massive-iguana-121.notion.site/3-37f521af4ac842ccba75a4fb590c506d",
            "URL_PRIVACY": "https://www.notion.so/3-3d0a9c55ddd74086b63582c308ca285e",
            "FRAMEWORK_SEARCH_PATHS": "$(inherited) $(PROJECT_DIR)",
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks",
            "OTHER_LDFLAGS": "$(inherited) -framework 'Accelerate' -framework 'CFNetwork'",
            "KAKAO_CHANNEL_URL": "http://pf.kakao.com/_RxghUb/chat"
        ]
        
        static let debug: SettingsDictionary = [
            "ADMOB_UNIT_ID_POLL_DETAIL": "ca-app-pub-3940256099942544/2435281174",
            "ADMOB_UNIT_ID_HOME_LIST": "ca-app-pub-3940256099942544/2435281174",
            "ADMOB_UNIT_ID_HOME_CARD": "ca-app-pub-3940256099942544/2435281174",
            "ADMOB_UNIT_ID_COMMUNITY": "ca-app-pub-3940256099942544/2435281174",
            "ADMOB_UNIT_ID_CATEGORY_FILTER": "ca-app-pub-3940256099942544/2435281174",
            "ADMOB_UNIT_ID_STORE_DETAIL": "ca-app-pub-3940256099942544/2435281174",
            "ADMOB_UNIT_ID_FRONT_BANNER": "ca-app-pub-3940256099942544/4411468910",
            "ADMOB_UNIT_ID_SEARCH_ADDRESS": "ca-app-pub-3940256099942544/2435281174",
            "ANDROID_PACKAGE_NAME": "com.zion830.threedollars.dev",
            "API_URL": "https://dev.threedollars.co.kr",
            "APP_DISPLAY_NAME": "가슴속3천원-Dev",
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
            "DEEP_LINK_SCHEME": "dollars-dev",
            "UNIVERSIAL_LINK_HOST": "https://app.dev.threedollars.co.kr",
            "KAKAO_APP_KEY": "95f91f9656806e132796f0071ab99aaa",
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket-debug",
            "PRODUCT_MODULE_NAME": "dollar_in_my_pocket",
            "PRODUCT_NAME": "dollar-in-my-pocket-debug",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-dev",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon-Dev"
        ]
        
        static let release: SettingsDictionary = [
            "ADMOB_UNIT_ID_POLL_DETAIL": "ca-app-pub-1527951560812478/5573281913",
            "ADMOB_UNIT_ID_HOME_LIST": "ca-app-pub-1527951560812478/4059484724",
            "ADMOB_UNIT_ID_HOME_CARD": "ca-app-pub-1527951560812478/4152389037",
            "ADMOB_UNIT_ID_COMMUNITY": "ca-app-pub-1527951560812478/9021572333",
            "ADMOB_UNIT_ID_CATEGORY_FILTER": "ca-app-pub-1527951560812478/3327283605",
            "ADMOB_UNIT_ID_STORE_DETAIL": "ca-app-pub-1527951560812478/5208914863",
            "ADMOB_UNIT_ID_FRONT_BANNER": "ca-app-pub-1527951560812478/1135797704",
            "ADMOB_UNIT_ID_SEARCH_ADDRESS": "ca-app-pub-1527951560812478/1646012090",
            "ANDROID_PACKAGE_NAME": "com.zion830.threedollars",
            "API_URL": "https://threedollars.co.kr",
            "APP_DISPLAY_NAME": "가슴속3천원",
            "DEEP_LINK_SCHEME": "dollars",
            "UNIVERSIAL_LINK_HOST": "https://app.threedollars.co.kr",
            "KAKAO_APP_KEY": "a0ce3cecac62e2dedf50751d5abc5740",
            "ONLY_ACTIVE_ARCH": "YES",
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket",
            "PRODUCT_NAME": "dollar-in-my-pocket",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-prod",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon"
        ]
    }
    
    struct AppTest {
        static let base: SettingsDictionary = [
            "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES": "YES",
            "BUNDLE_LOADER": "$(TEST_HOST)",
            "CODE_SIGN_STYLE": "Automatic",
            "DEVELOPMENT_TEAM": "X975A2HM62",
            "PRODUCT_NAME": "$(TARGET_NAME)",
            "SWIFT_VERSION": "5.0",
            "TARGETED_DEVICE_FAMILY": "1,2",
            "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/dollar-in-my-pocket-debug.app/dollar-in-my-pocket-debug"
        ]
        
        static let debug: SettingsDictionary = [
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks @loader_path/Frameworks"
        ]
        
        static let release: SettingsDictionary = [
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks @loader_path/Frameworks"
        ]
    }
    
    struct ServiceExtension {
        static let base: SettingsDictionary = [
            "MARKETING_VERSION": DefaultSetting.appVersion,
            "CURRENT_PROJECT_VERSION": DefaultSetting.buildNumber,
            "CLANG_CXX_LANGUAGE_STANDARD": "gnu++17",
            "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES",
            "CODE_SIGN_IDENTITY": "Apple Development",
            "CODE_SIGN_IDENTITY[sdk=iphoneos*]": "iPhone Developer",
            "CODE_SIGN_STYLE": "Manual",
            "DEVELOPMENT_TEAM": "",
            "DEVELOPMENT_TEAM[sdk=iphoneos*]": "X975A2HM62",
            "GENERATE_INFOPLIST_FILE": "YES",
            "INFOPLIST_KEY_CFBundleDisplayName": "service-extension",
            "INFOPLIST_KEY_NSHumanReadableCopyright": "Copyright © 2022 Macgongmon. All rights reserved.",
            "PRODUCT_NAME": "$(TARGET_NAME)",
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "SKIP_INSTALL": "YES",
            "SWIFT_EMIT_LOC_STRINGS": "YES",
            "SWIFT_VERSION": "5.0",
            "TARGETED_DEVICE_FAMILY": "1",
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks"
        ]
        
        static let debug: SettingsDictionary = [
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket-debug.service-extension",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-service-extension-dev"
        ]
        
        static let release: SettingsDictionary = [
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket.service-extension",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-service-extension-prod"
        ]
    }
    
    struct ContentExtension {
        static let base: SettingsDictionary = [
            "MARKETING_VERSION": DefaultSetting.appVersion,
            "CURRENT_PROJECT_VERSION": DefaultSetting.buildNumber,
            "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES",
            "CODE_SIGN_IDENTITY": "Apple Development",
            "CODE_SIGN_IDENTITY[sdk=iphoneos*]": "iPhone Developer",
            "CODE_SIGN_STYLE": "Manual",
            "DEVELOPMENT_TEAM": "",
            "DEVELOPMENT_TEAM[sdk=iphoneos*]": "X975A2HM62",
            "PRODUCT_NAME": "$(TARGET_NAME)",
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "SKIP_INSTALL": "YES",
            "SWIFT_VERSION": "5.0",
            "TARGETED_DEVICE_FAMILY": "1,2",
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks"
        ]
        
        static let debug: SettingsDictionary = [
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket-debug.content-extension",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-content-extension-dev"
        ]
        
        static let release: SettingsDictionary = [
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket.content-extension",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-content-extension-prod"
        ]
    }
}

struct Script {
    static let googleService = """
    # Type a script or drag a script file from your workspace to insert its path.
    case "${CONFIGURATION}" in
        "Debug" )
    cp -r "$SRCROOT/Targets/three-dollar-in-my-pocket/Config/firebase/GoogleService-Info-Dev.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist" ;;
          "Release" )
    cp -r "$SRCROOT/Targets/three-dollar-in-my-pocket/Config/firebase/GoogleService-Info-Prod.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist" ;;
    *)
    ;;
    esac
    """
    
    static let firebaseCrashlytics = "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
}

// MARK: - Project
let project = Project(
    name: "3dollar-in-my-pocket",
    organizationName: "macgongmon",
    packages: [
        .kakaoSDK,
        .swiftyBeaver,
        .deviceKit,
        .permissionsKit,
        .firebaseSDK,
        .netfox,
        .admob
    ],
    settings: .settings(
        base: BuildSetting.Project.base,
        configurations: [
            .debug(name: .debug, settings: BuildSetting.Project.debug),
            .release(name: .release, settings: BuildSetting.Project.release)
        ]),
    targets: [
        .target(
            name: "three-dollar-in-my-pocket",
            destinations: .iOS,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: .iOS("18.0"),
            infoPlist: "Targets/three-dollar-in-my-pocket/Info.plist",
            sources: ["Targets/three-dollar-in-my-pocket/Sources/**"],
            resources: ["Targets/three-dollar-in-my-pocket/Resources/**"],
            entitlements: .file(path: .relativeToManifest("Targets/three-dollar-in-my-pocket/three-dollar-in-my-pocket.entitlements")),
            scripts: [
                .pre(script: Script.googleService, name: "GoogleService Info"),
                .post(script: Script.firebaseCrashlytics, name: "FirebaseCrashlytics", inputPaths: [
                    .glob(.relativeToManifest("${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}")),
                    .glob(.relativeToManifest("$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)"))
                ])
            ],
            dependencies: [
                .Core.networking,
                .Core.common,
                .Core.dependencyInjection,
                .Core.designSystem,
                .Interface.appInterface,
                .Interface.storeInterface,
                .Interface.writeInterface,
                .Interface.communityInterface,
                .Feature.home,
                .Feature.community,
                .Feature.membership,
                .Feature.store,
                .Feature.write,
                .Feature.myPage,
                .SPM.snapKit,
                .SPM.then,
                .SPM.kingfisher,
                .SPM.lottie,
                .Package.cameraPermission,
                .Package.deviceKit,
                .Package.firebaseAnalytics,
                .Package.firebaseCrashlytics,
                .Package.firebaseFirestore,
                .Package.firebaseMessaging,
                .Package.firebaseRemoteConfig,
                .Package.kakaoSDK,
                .Package.kakaoSDKAuth,
                .Package.kakaoSDKCommon,
                .Package.kakaoSDKShare,
                .Package.kakaoSDKTalk,
                .Package.kakaoSDKTemplate,
                .Package.kakaoSDKUser,
                .Package.locationAlwaysPermission,
                .Package.locationWhenInUsePermission,
                .Package.photoLibraryPermission,
                .Package.swiftyBeaver,
                .Package.netfox,
                .Package.admob,
                .Framework.naverMap,
                .Framework.naverGeometry,
                .target(name: "service-extension"),
                .target(name: "content-extension"),
            ],
            settings: .settings(
                base: BuildSetting.App.base,
                configurations: [
                    .debug(name: .debug, settings: BuildSetting.App.debug),
                    .release(name: .release, settings: BuildSetting.App.release)
                ])
        ),
        .target(
            name: "three-dollar-in-my-pocketTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.macgongmon.-dollar-in-my-pocketTests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: "Targets/three-dollar-in-my-pocketTests/Info.plist",
            sources: ["Targets/three-dollar-in-my-pocketTests/Sources/**"],
            resources: ["Targets/three-dollar-in-my-pocketTests/Resources/**"],
            dependencies: [
                .target(name: "three-dollar-in-my-pocket"),
            ],
            settings: .settings(
                base: BuildSetting.AppTest.base,
                configurations: [
                    .debug(name: .debug, settings: BuildSetting.AppTest.debug),
                    .release(name: .release, settings: BuildSetting.AppTest.release)
                ])
        ),
        .target(
            name: "service-extension",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: .iOS("18.0"),
            infoPlist: "Targets/service-extension/Info.plist",
            sources: ["Targets/service-extension/Sources/**"],
            dependencies: [],
            settings: .settings(
                base: BuildSetting.ServiceExtension.base,
                configurations: [
                    .debug(name: .debug, settings: BuildSetting.ServiceExtension.debug),
                    .release(name: .release, settings: BuildSetting.ServiceExtension.release)
                ])
        ),
        .target(
            name: "content-extension",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            infoPlist: "Targets/content-extension/Info.plist",
            sources: ["Targets/content-extension/Sources/**"],
            resources: ["Targets/content-extension/Resources/**"],
            dependencies: [
                .sdk(name: "UserNotifications", type: .framework, status: .optional),
                .sdk(name: "UserNotificationsUI", type: .framework, status: .optional)
            ],
            settings: .settings(
                base: BuildSetting.ContentExtension.base,
                configurations: [
                    .debug(name: .debug, settings: BuildSetting.ContentExtension.debug),
                    .release(name: .release, settings: BuildSetting.ContentExtension.release)
                ])
        ),
        .target(
            name: "AppInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.app-interface",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Targets/AppInterface/Sources/**"],
            dependencies: [
                .Core.dependencyInjection,
                .Core.model
            ]
        )
    ],
    schemes: [
        .scheme(
            name: "three-dollar-in-my-pocket-debug",
            buildAction: .buildAction(targets: ["three-dollar-in-my-pocket"]),
            runAction: .runAction(
                configuration: .debug,
                attachDebugger: true,
                arguments: .arguments(launchArguments: [.launchArgument(name: "-FIRDebugEnabled", isEnabled: true)])
            ),
            archiveAction: .archiveAction(configuration: .debug)
        ),
        .scheme(
            name: "three-dollar-in-my-pocket",
            buildAction: .buildAction(targets: ["three-dollar-in-my-pocket"]),
            runAction: .runAction(
                configuration: .release,
                attachDebugger: true
            )
        ),
        .scheme(
            name: "three-dollar-in-my-pocketTests",
            buildAction: .buildAction(targets: ["three-dollar-in-my-pocketTests"]),
            testAction: .targets(["three-dollar-in-my-pocketTests"]),
            runAction: .runAction(
                configuration: .debug,
                attachDebugger: false
            )
        ),
        .scheme(
            name: "content-extension",
            buildAction: .buildAction(targets: ["content-extension", "three-dollar-in-my-pocket"])
        ),
        .scheme(
            name: "service-extension",
            buildAction: .buildAction(targets: ["service-extension", "three-dollar-in-my-pocket"])
        )
    ]
)
