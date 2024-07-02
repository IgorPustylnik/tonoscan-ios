import Foundation

class RequestService {
    public static let shared = RequestService()
    
    // MARK: - Basic request constructor
    
    private func sendRequest(_ jsonData: Data?, url: String, auth: String?, completion: @escaping (String?, Bool, Int?) -> Void) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            completion(nil, false, nil)
            return
        }
        
        var request = URLRequest(url: url)
        if let jsonData = jsonData {
            request.httpMethod = "POST"
            request.httpBody = jsonData
        } else {
            request.httpMethod = "GET"
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let auth = auth {
            request.setValue("Bearer \(auth)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error:", error.localizedDescription)
                completion(nil, false, nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(nil, false, nil)
                return
            }
            
            if (200..<300).contains(httpResponse.statusCode) {
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    completion(responseBody, true, httpResponse.statusCode)
                } else {
                    print("Failed to convert data to string")
                    completion(nil, false, httpResponse.statusCode)
                }
            } else {
                print("Server returned status code:", httpResponse.statusCode)
                completion(nil, false, httpResponse.statusCode)
            }
        }
        
        task.resume()
    }
    
    // never used
    public func pingServer(completion: @escaping ((Bool) -> Void)) {
        sendRequest(nil, url: "https://tonometer.onrender.com/", auth: nil) { a, b, code in
            guard let code = code else { return }
            if (200..<499).contains(code) {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    // MARK: - Auth requests
    
    public func tempRegister(with userRequest: RegisterRequest,
                             completion: @escaping (Bool, Error?) -> Void) {
        let userFullName = userRequest.userFullName
        let password = userRequest.password
        let email = userRequest.email
        let json: [String: Any] = [
               "userFullName": userFullName,
               "password": password,
               "email": email,
               "role": "Client"
           ]
           
           do {
               let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
               sendRequest(jsonData, url: "https://tonometer.onrender.com/auth/temporal-register", auth: nil) {
                   response, ok, code in
                   completion(ok, nil)
            }
           } catch {
               completion(false, error)
               print("Error converting to JSON:", error.localizedDescription)
           }
    }
    
    public func confirmRegister(with userRequest: ConfirmRegisterRequest,
                             completion: @escaping (Bool, Error?) -> Void) {
        let userFullName = userRequest.userFullName
        let password = userRequest.password
        let email = userRequest.email
        let tempPassword = userRequest.tempPassword
        let json: [String: Any] = [
               "userFullName": userFullName,
               "password": password,
               "email": email,
               "role": "Client",
               "tempPassword": tempPassword
           ]
           
           do {
               let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
               sendRequest(jsonData, url: "https://tonometer.onrender.com/auth/confirm-register", auth: nil) { response, ok, code in
                   completion(ok, nil)
               }
           } catch {
               completion(false, error)
               print("Error converting to JSON:", error.localizedDescription)
           }
    }
    
    public func signIn(with userRequest: SignInRequest,
                      completion: @escaping (String?, Error?) -> Void) {
        let email = userRequest.email
        let password = userRequest.password
        let json: [String: Any] = [
                "email": email,
               "password": password
           ]
           do {
               let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
               sendRequest(jsonData, url: "https://tonometer.onrender.com/auth/login", auth: nil, completion: { response, ok, code in
                   if let response = response {
                       completion(response, nil)
                       return
                   }
                   print("login request error (response empty)")
                   completion(nil, nil)
               })
           } catch {
               completion(nil, error)
               print("Error converting to JSON:", error.localizedDescription)
           }
    }
    
    public func loadDataWithToken(with userRequest: LoadDataRequest,
                                  completion: @escaping (UserData?, Error?) -> Void) {
        let token = userRequest.token
        
        DispatchQueue.global().async {
            self.sendRequest(nil, url: "https://tonometer.onrender.com/tonometer-api/get-user-data", auth: token) { response, ok, code in
                guard ok else {
                    completion(nil, nil)
                    return
                }
                
                guard let responseData = response?.data(using: .utf8) else {
                    completion(nil, nil)
                    return
                }
                
                do {
                    let userData = try JSONDecoder().decode(UserData.self, from: responseData)
                    print("USERDATA LOADED FROM SEVER: \(userData)")
                    completion(userData, nil)
                } catch {
                    print("Error decoding JSON:", error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    }
    
    public func sendNumbers(with userRequest: SendNumbersRequest,
                            completion: @escaping (Bool, Error?) -> Void) {
        let token = userRequest.token
        let numbers = userRequest.numbers
        let json: [String: Any] = [
            "phone": numbers
        ]
        print("NUMBERS SENT TO SERVER: \(json)")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            sendRequest(jsonData, url: "https://tonometer.onrender.com/tonometer-api/add-relatives", auth: token, completion: { response, ok, code in
                completion(ok, nil)
            })
        } catch {
            completion(false, error)
            print("Error converting to JSON:", error.localizedDescription)
        }
    }
    
    public func sendImage(with userRequest: ImageRequest,
                          completion: @escaping (String?, Error?, Int?) -> Void) {
        let token = userRequest.token
        let image = userRequest.image
        let date = userRequest.date
        let json: [String: Any] = [
            "photo": image,
            "date": date
        ]
        print("SENDING IMAGE TO SERVER: \(date)")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            sendRequest(jsonData, url: "https://tonometer.onrender.com/tonometer-api/parse-image", auth: token, completion: {
                response, error, code in
                completion(response, nil, code)
            })
        } catch {
            completion(nil, error, nil)
            print("Error converting to JSON:", error.localizedDescription)
        }
    }
}
