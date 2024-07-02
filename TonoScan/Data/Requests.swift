struct RegisterRequest {
    let userFullName: String
    let password: String
    let email: String
}

struct ConfirmRegisterRequest {
    let userFullName: String
    let password: String
    let email: String
    let tempPassword: String
}

struct SignInRequest {
    let email: String
    let password: String
}

struct LoadDataRequest {
    let token: String
}

struct SendNumbersRequest {
    let token: String
    let numbers: [String]
}

struct ImageRequest {
    let token: String
    let image: [UInt8]
    let date: String
}
