---
name: ios-repository-pattern
description: iOS Repository 패턴 정의. Protocol + Impl 구조 및 API enum + RequestType 확장 패턴으로 네트워크 레이어를 구현합니다. async/await와 Result 타입을 사용하며, 다른 iOS 프로젝트에서도 재사용 가능합니다.
---

# iOS Repository 패턴

## 개요

Protocol + Impl 구조로 Repository를 구현하고, API enum + RequestType 확장으로 네트워크 요청을 정의합니다. async/await와 Result 타입을 사용하여 비동기 처리를 간결하게 합니다.

## 핵심 원칙

1. **Protocol + Impl 분리**: Repository는 Protocol로 정의하고 Impl 구조체로 구현
2. **API enum 사용**: 각 API는 enum case로 정의
3. **RequestType 확장**: param, method, header, path를 구현
4. **async/await + Result**: 모든 메서드는 async이며 Result<Success, Error>를 반환
5. **NetworkManager 통합**: 네트워크 호출은 NetworkManager.shared.request()로 일원화

## 구조

### 1. Repository Protocol

```swift
public protocol MyRepository {
    func fetchData(input: FetchDataInput) async -> Result<MyDataResponse, Error>
    func saveData(id: String, isDelete: Bool) async -> Result<String, Error>
}
```

**규칙**:
- public 접근 제어자 사용
- 모든 메서드는 async
- 반환 타입은 Result<Success, Error>
- 메서드명: fetch, save, update, delete 등 CRUD 동사 사용
- Input 타입은 별도 구조체로 정의 (여러 파라미터가 필요한 경우)

### 2. Repository Impl

```swift
public struct MyRepositoryImpl: MyRepository {
    public init() { }

    public func fetchData(input: FetchDataInput) async -> Result<MyDataResponse, Error> {
        let request = MyApi.fetchData(input: input)
        return await NetworkManager.shared.request(requestType: request)
    }

    public func saveData(id: String, isDelete: Bool) async -> Result<String, Error> {
        let request = MyApi.saveData(id: id, isDelete: isDelete)
        return await NetworkManager.shared.request(requestType: request)
    }
}
```

**규칙**:
- struct로 구현 (상태 없음)
- public init() 필수
- NetworkManager.shared.request() 호출
- API enum을 생성하여 전달

### 3. API enum

```swift
enum MyApi {
    case fetchData(input: FetchDataInput)
    case saveData(id: String, isDelete: Bool)
}
```

**규칙**:
- enum으로 정의
- 각 case는 API 엔드포인트를 나타냄
- associated value로 필요한 파라미터 전달
- 네이밍: 서버 API 문서와 동일하게 (camelCase)

### 4. RequestType 확장

```swift
extension MyApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchData(let input):
            return input
        case .saveData:
            return nil
        }
    }

    var method: RequestMethod {
        switch self {
        case .fetchData:
            return .get
        case .saveData(_, let isDelete):
            return isDelete ? .delete : .put
        }
    }

    var header: HTTPHeaderType {
        switch self {
        case .fetchData(let input):
            return .custom([
                "X-Custom-Header": input.value
            ])
        default:
            return .default
        }
    }

    var path: String {
        switch self {
        case .fetchData(let input):
            return "/api/v1/data/\(input.id)"
        case .saveData(let id, _):
            return "/api/v1/data/\(id)"
        }
    }
}
```

**규칙**:
- param: Encodable? - 요청 바디 또는 쿼리 파라미터
- method: RequestMethod - HTTP 메서드 (.get, .post, .put, .delete, .patch)
- header: HTTPHeaderType - HTTP 헤더 (.default, .json, .custom([...]))
- path: String - API 경로 (동적 파라미터 포함 가능)

## 전체 흐름

```
1. API enum 정의
   ↓
2. RequestType 확장 (param, method, header, path)
   ↓
3. Repository Protocol 정의
   ↓
4. Repository Impl 구현 (NetworkManager 호출)
```

## 전체 템플릿

```swift
import Foundation
import Model

// 1. API enum 정의
enum MyApi {
    case fetchData(input: FetchDataInput)
    case saveData(id: String, isDelete: Bool)
    case updateData(id: Int, input: UpdateDataInput)
}

// 2. RequestType 확장
extension MyApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchData(let input):
            return input
        case .saveData:
            return nil
        case .updateData(_, let input):
            return input
        }
    }

    var method: RequestMethod {
        switch self {
        case .fetchData:
            return .get
        case .saveData(_, let isDelete):
            return isDelete ? .delete : .put
        case .updateData:
            return .patch
        }
    }

    var header: HTTPHeaderType {
        switch self {
        case .fetchData:
            return .json
        case .saveData:
            return .json
        case .updateData:
            return .custom(["X-Nonce-Token": "token"])
        }
    }

    var path: String {
        switch self {
        case .fetchData(let input):
            return "/api/v1/data/\(input.id)"
        case .saveData(let id, _):
            return "/api/v1/data/\(id)"
        case .updateData(let id, _):
            return "/api/v1/data/\(id)"
        }
    }
}

// 3. Repository Protocol
public protocol MyRepository {
    func fetchData(input: FetchDataInput) async -> Result<MyDataResponse, Error>
    func saveData(id: String, isDelete: Bool) async -> Result<String, Error>
    func updateData(id: Int, input: UpdateDataInput) async -> Result<MyDataResponse, Error>
}

// 4. Repository Impl
public struct MyRepositoryImpl: MyRepository {
    public init() { }

    public func fetchData(input: FetchDataInput) async -> Result<MyDataResponse, Error> {
        let request = MyApi.fetchData(input: input)
        return await NetworkManager.shared.request(requestType: request)
    }

    public func saveData(id: String, isDelete: Bool) async -> Result<String, Error> {
        let request = MyApi.saveData(id: id, isDelete: isDelete)
        return await NetworkManager.shared.request(requestType: request)
    }

    public func updateData(id: Int, input: UpdateDataInput) async -> Result<MyDataResponse, Error> {
        let request = MyApi.updateData(id: id, input: input)
        return await NetworkManager.shared.request(requestType: request)
    }
}
```

## param 처리 패턴

### Input 객체 전달 (GET)
```swift
case .fetchData(let input):
    return input  // Encodable 구조체
```

### nil 반환 (파라미터 없음)
```swift
case .saveData:
    return nil
```

### 딕셔너리 반환 (간단한 파라미터)
```swift
case .reportStore(_, let reportReason):
    return ["deleteReasonType": reportReason]
```

### 조건부 파라미터 (cursor 등)
```swift
case .fetchStorePhotos(let storeId, let cursor):
    var params = ["storeId": "\(storeId)"]
    if let cursor {
        params["cursor"] = cursor
    }
    return params
```

### 배열 파라미터
```swift
case .fetchDisplayItems(_, let itemTypes):
    return ["itemTypes": itemTypes.map { $0.rawValue }]
```

## method 처리 패턴

### 고정 메서드
```swift
case .fetchData:
    return .get
```

### 동적 메서드 (isDelete 등)
```swift
case .saveData(_, let isDelete):
    return isDelete ? .delete : .put
```

## header 처리 패턴

### 기본 헤더
```swift
case .fetchData:
    return .json  // 또는 .default
```

### 위치 헤더 (GPS)
```swift
case .fetchAroundStores:
    return .location
```

### 커스텀 헤더
```swift
case .createStore(_, let token):
    return .custom(["X-Nonce-Token": token])
```

### 여러 헤더
```swift
case .fetchBossStoreDetail(let input):
    return .custom([
        "X-Device-Latitude": String(input.latitude),
        "X-Device-Longitude": String(input.longitude)
    ])
```

## path 처리 패턴

### 동적 파라미터 포함
```swift
case .fetchData(let input):
    return "/api/v1/data/\(input.id)"
```

### 여러 동적 파라미터
```swift
case .togglePostSticker(let storeId, let postId, _):
    return "/api/v1/store/\(storeId)/news-post/\(postId)/stickers"
```

## 실제 사용 예시

### StoreRepository (참고)

```swift
// Repository Protocol
public protocol StoreRepository {
    func fetchStoreContributorHistories(storeId: Int, cursor: String?) async -> Result<StoreContributorHistoriesSection, Error>
    func saveStore(storeId: String, isDelete: Bool) async -> Result<String, Error>
}

// Repository Impl
public struct StoreRepositoryImpl: StoreRepository {
    public init() { }

    public func fetchStoreContributorHistories(storeId: Int, cursor: String?) async -> Result<StoreContributorHistoriesSection, Error> {
        let request = StoreApi.fetchStoreContributorHistories(storeId: storeId, cursor: cursor)
        return await NetworkManager.shared.request(requestType: request)
    }

    public func saveStore(storeId: String, isDelete: Bool) async -> Result<String, Error> {
        let request = StoreApi.saveStore(storeId: storeId, isDelete: isDelete)
        return await NetworkManager.shared.request(requestType: request)
    }
}

// API enum
enum StoreApi {
    case fetchStoreContributorHistories(storeId: Int, cursor: String?)
    case saveStore(storeId: String, isDelete: Bool)
}

// RequestType 확장
extension StoreApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchStoreContributorHistories(_, let cursor):
            if let cursor {
                return ["cursor": cursor]
            } else {
                return nil
            }
        case .saveStore:
            return nil
        }
    }

    var method: RequestMethod {
        switch self {
        case .fetchStoreContributorHistories:
            return .get
        case .saveStore(_, let isDelete):
            return isDelete ? .delete : .put
        }
    }

    var header: HTTPHeaderType {
        switch self {
        case .fetchStoreContributorHistories:
            return .json
        case .saveStore:
            return .json
        }
    }

    var path: String {
        switch self {
        case .fetchStoreContributorHistories(let storeId, _):
            return "/v1/screen/store/\(storeId)/contributors/section/histories"
        case .saveStore(let storeId, _):
            return "/api/v2/store/\(storeId)/favorite"
        }
    }
}
```

## 사용 시 주의사항

1. **API 네이밍은 서버와 동일하게**: 서버 API 문서의 이름을 그대로 사용합니다 (camelCase로 변환)
2. **Result 타입 일관성 유지**: 모든 메서드는 Result<Success, Error>를 반환합니다
3. **에러는 NetworkManager에서 처리**: Repository에서는 에러를 그대로 전달합니다
4. **public 접근 제어자**: Protocol과 Impl 모두 public으로 선언합니다
5. **struct로 구현**: Repository Impl은 struct로 구현합니다 (상태 없음)
6. **동적 파라미터**: path에서 \(변수) 형태로 동적 파라미터를 포함할 수 있습니다
7. **조건부 메서드**: isDelete 등의 플래그로 HTTP 메서드를 동적으로 결정할 수 있습니다

## ViewModel에서 사용

```swift
@MainActor
private func fetchData() async {
    guard !state.isLoading else { return }
    state.isLoading = true

    let result = await dependency.repository.fetchData(
        input: FetchDataInput(id: config.id)
    )

    state.isLoading = false

    switch result {
    case .success(let response):
        output.items.send(response.items)

    case .failure(let error):
        output.error.send(error)
    }
}
```

## 테스트

테스트 시 Mock Repository를 생성할 수 있습니다:

```swift
final class MockMyRepository: MyRepository {
    var fetchDataResult: Result<MyDataResponse, Error>?

    func fetchData(input: FetchDataInput) async -> Result<MyDataResponse, Error> {
        guard let result = fetchDataResult else {
            return .failure(NSError(domain: "Mock", code: -1))
        }
        return result
    }

    func saveData(id: String, isDelete: Bool) async -> Result<String, Error> {
        return .success("OK")
    }
}
```

## 파일 구조

```
Modules/Core/Network/Sources/
├── API/
│   ├── StoreApi.swift           # API enum + RequestType 확장
│   ├── UserApi.swift
│   └── ...
└── Repository/
    ├── StoreRepository.swift    # Protocol + Impl
    ├── UserRepository.swift
    └── ...
```

**규칙**:
- API와 Repository는 별도 파일로 관리
- 하나의 도메인(Store, User 등)은 하나의 Repository로 관리
- API enum은 같은 도메인의 모든 API를 포함
