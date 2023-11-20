struct UserResponse: Decodable {
    let medal: MedalResponse
    let name: String
    let socialType: String
    let userId: Int
}
