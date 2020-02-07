import Alamofire

extension DataResponse {
    func flatMapResult<T>(_ transform: (Value) -> Result<T>) -> DataResponse<T> {
        let result: Result<T>
        
        switch self.result {
        case .success(let value):
            result = transform(value)
        case .failure(let error):
            result = .failure(error)
        }
        return DataResponse<T>(request: self.request, response: self.response,
            data: self.data, result: result, timeline: self.timeline
        )
    }
}
