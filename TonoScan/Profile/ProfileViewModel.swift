import Foundation

struct ProfileModel {
    var id: Int
    var email: String
    var name: String
    var numbers: [String]
    var medicalRecordLink: String
}

class ProfileViewModel {
    static var data = ProfileViewModel()
    private(set) var shared: ProfileModel =
    ProfileModel(
        id: 0,
        email: "default@default.ru",
        name: "Старухина Бабка Ивановна",
        numbers: ["default", "default"],
        medicalRecordLink: "https://1tv.ru/"
    )
    
    public func setName(_ name: String) {
        shared.name = name
    }
    
    public func setNumbers(_ numbers: [String]) {
        shared.numbers = numbers
    }
    
    public func setWithUserData(userData: UserData) {
        print("set pvm with user data")
        shared = ProfileModel(
            id: userData.id,
            email: userData.email,
            name: userData.fullName,
            numbers: userData.relativesPhoneNumber,
            medicalRecordLink: "https://1tv.ru/"
        )
    }
    
    public func setDefault() {
        shared = ProfileModel(
            id: 0,
            email: "default@default.ru",
            name: "Старухина Бабка Ивановна",
            numbers: ["default", "default"],
            medicalRecordLink: "https://1tv.ru/"
        )
    }
}
