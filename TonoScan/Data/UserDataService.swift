import Foundation

struct UserData: Codable {
    let id: Int
    let email: String
    var fullName: String
    var relativesPhoneNumber: [String]
}

class UserDataService {
    public static var shared = UserDataService()
    
    public func saveTokenToMemory(token: String) {
        KeychainService.shared.saveToken(token: token)
    }
    
    public func getTokenFromMemory() -> String? {
        guard let data = KeychainService.shared.getToken() else {
            print("Token not found")
            return nil
        }
        return data
    }
    
    public func deleteTokenFromMemory() {
        KeychainService.shared.deleteToken()
    }
    
    public func loadDataFromServerToMemory(completion: @escaping (() -> Void)) {
        guard let token = getTokenFromMemory() else {
            completion()
            return
        }
        let rqst = LoadDataRequest(token: token)

        DispatchQueue.global().async {
            RequestService.shared.loadDataWithToken(with: rqst) { data, error in
                guard let userData = data else {
                    if let localData = KeychainService.shared.getUserData() {
                        ProfileViewModel.data.setWithUserData(userData: localData)
                    }
                    print("Failed to load userdata to keychain")
                    completion()
                    return
                }

                DispatchQueue.global().async {
                    KeychainService.shared.saveUserData(userData: userData)
                    ProfileViewModel.data.setWithUserData(userData: userData)
                    completion()
                }
            }
        }
    }
    
    public func deleteDataFromMemory() {
        KeychainService.shared.deleteUserData()
        ProfileViewModel.data.setDefault()
    }
    
    public func loadDataToViewModel() -> UserData? {
        guard let userData = KeychainService.shared.getUserData() else {
            print("Failed to load userdata from keychain")
            return nil
        }
        ProfileViewModel.data.setWithUserData(userData: userData)
        print("PVM was configured with userdata")
        return userData
    }
    
    public func saveDataToKeychainFromPVM() {
        let pvm = ProfileViewModel.data.shared
        KeychainService.shared.saveUserData(
            userData: UserData(
                id: pvm.id,
                email: pvm.email,
                fullName: pvm.name,
                relativesPhoneNumber: pvm.numbers
            )
        )
    }
}
