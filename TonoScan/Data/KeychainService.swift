import Foundation
import Security

class KeychainService {
    public static var shared = KeychainService()
    
    private static let tokenKey = "com.igorpustylnik.TonoScan.user_token"
    private static let userDataKey = "com.igorpustylnik.TonoScan.user_data"
    private static let imagesKey = "com.igorpustylnik.TonoScan.images"

    public func saveToken(token: String) {
        saveValue(value: token, forKey: KeychainService.tokenKey)
    }

    public func getToken() -> String? {
        if let savedData: String = loadValue(forKey: KeychainService.tokenKey) {
            if let jsonData = savedData.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        if let token = json["token"] as? String {
                            return token
                        }
                    }
                } catch {
                    print("Error parsing token: \(error)")
                }
                
            }
        }
        return nil
    }

    public func deleteToken() {
        deleteValue(forKey: KeychainService.tokenKey)
    }

    public func saveUserData(userData: UserData) {
        saveValue(value: userData, forKey: KeychainService.userDataKey)
    }

    public func getUserData() -> UserData? {
        return loadValue(forKey: KeychainService.userDataKey)
    }

    public func deleteUserData() {
        deleteValue(forKey: KeychainService.userDataKey)
    }
    
    public func saveImages(images: [ImageInfo]) {
        print("SAVED IMAGES: \(images)")
        saveValue(value: images, forKey: KeychainService.imagesKey)
    }
    
    public func getImages() -> [ImageInfo]? {
        return loadValue(forKey: KeychainService.imagesKey)
    }
    
    public func deleteImages() {
        deleteValue(forKey: KeychainService.imagesKey)
    }

    public func saveValue<T: Codable>(value: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            
            SecItemDelete(query as CFDictionary)
            
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else { return }
        } catch {
            print("Error saving value to Keychain: \(error)")
        }
    }

    private func loadValue<T: Codable>(forKey key: String) -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnAttributes as String: kCFBooleanTrue!,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &queryResult)

        guard status == errSecSuccess, let item = queryResult as? [String: Any], let data = item[kSecValueData as String] as? Data else { return nil }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Error loading value from Keychain: \(error)")
            return nil
        }
    }

    private func deleteValue(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
