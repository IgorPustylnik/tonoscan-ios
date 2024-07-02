import Foundation
import UIKit

struct ImageResponse: Codable {
    let dia: Int
    let sys: Int
    let pulse: Int
}
    
struct ImageInfo: Codable {
    let name: String
    let date: Date
}

class ImageQueueService {
    public static var shared = ImageQueueService()
    private var timer: Timer?
    private let loadingAlert = LoadingAlert(message: "Отправка фото...")
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(tryImageQueue), userInfo: nil, repeats: true)
    }
    
    private func queueIsEmpty() -> Bool? {
        guard let images = KeychainService.shared.getImages() else {
            return nil
        }
        return images.isEmpty
    }
    
    private func documentsURL() -> URL {
        let fileManager = FileManager.default
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return documentsURL
        } catch {
            print("Error: \(error)")
        }
        return URL(string: "")!
        
    }
    
    public func addToQueue(imageInfo: ImageInfo) {
        guard var images = KeychainService.shared.getImages() else {
            var images: [ImageInfo] = []
            images.append(imageInfo)
            KeychainService.shared.saveImages(images: images)
            print("Added to queue: \(imageInfo)")
            return
        }
        images.append(imageInfo)
        KeychainService.shared.saveImages(images: images)
        print("Added to queue: \(imageInfo)")
    }
    
    private func removeFirstFromQueue() {
        guard var images = KeychainService.shared.getImages() else {
            print("(remove first from queue) Failed to load from keychain")
            return
        }
        do {
            // force-unwrap потому что метод вызывается только тогда, когда очередь - не пустая
            try FileManager.default.removeItem(at: documentsURL().appendingPathComponent(images.first!.name))
        } catch {
            print("ERROR DELETING: \(error)")
        }
        images.removeFirst()
        KeychainService.shared.saveImages(images: images)
    }
    
    private func processFirstFromQueue(completion: @escaping((ImageResponse?, ImageInfo?, Int?) -> Void)) {
        let fileManager = FileManager.default
        do {
            print("CONTENTS: \(try fileManager.contentsOfDirectory(at: documentsURL(), includingPropertiesForKeys: []))")
        } catch {
            print(error)
        }
        
        guard let queue = ImageQueueService.shared.getImagesFromMemory() else {
            completion(nil, nil, nil)
            return
        }
        guard let token = UserDataService.shared.getTokenFromMemory() else {
            completion(nil, nil, nil)
            return
        }
        let imageInfo = queue.first!
        guard let converted = ImageQueueService.getArrayOfBytesFromImage(imageName: imageInfo.name) else {
            completion(nil, nil, nil)
            return
        }
        
        let imageRequest = ImageRequest(token: token, image: converted, date: ISO8601DateFormatter().string(from: imageInfo.date))
        RequestService.shared.sendImage(with: imageRequest) { response, error, code in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil, nil, nil)
                    return
                }
                guard let code = code else {
                    print("No response code (first image from queue)")
                    completion(nil, imageInfo, 999)
                    return
                }
                guard let responseData = response?.data(using: .utf8) else {
                    print("Send image response empty")
                    completion(nil, imageInfo, code)
                    return
                }
                do {
                    print(response)
                    let imageResponse = try JSONDecoder().decode(ImageResponse.self, from: responseData)
                    print("IMAGE RESPONSE: \(imageResponse)")
                    completion(imageResponse, imageInfo, code)
                } catch {
                    print("Error decoding JSON:", error.localizedDescription)
                    completion(nil, imageInfo, code)
                }
            }
        }
    }
    
    private static func getArrayOfBytesFromImage(imageName: String) -> [UInt8]? {
        let imageURL = ImageQueueService.shared.documentsURL().appendingPathComponent(imageName)
        do {
            let imageData = try Data(contentsOf: imageURL)
            let count = imageData.count
            var bytes = [UInt8](repeating: 0, count: count)
            imageData.copyBytes(to: &bytes, count: count)
            return bytes
        } catch {
            print("Error loading image data: \(error)")
            ImageQueueService.shared.removeFirstFromQueue()
            return nil
        }
    }
    
    // MARK: - Keychain
    
    private func saveImagesToMemory(images: [ImageInfo]) {
        KeychainService.shared.saveImages(images: images)
    }
    
    private func getImagesFromMemory() -> [ImageInfo]? {
        guard let images = KeychainService.shared.getImages() else {
            print("Failed to get images")
            return nil
        }
        return images
    }
    
    public func deleteImagesFromMemory() {
        let fileManager = FileManager.default
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
                print("Файл \(fileURL.lastPathComponent) успешно удален")
            }
        } catch {
            print("Ошибка при удалении файлов: \(error)")
        }
        guard let _ = KeychainService.shared.getImages() else { return }
        KeychainService.shared.deleteImages()
    }
    
    // MARK: - Main queue method
    
    @objc public func tryImageQueue() {
        guard let empty = ImageQueueService.shared.queueIsEmpty() else {
            return
        }
        if !empty && Reachability.isConnectedToNetwork() {
            print("TRIED IMAGE QUEUE")
            guard let window = UIApplication.shared.windows.first else { return }
            guard let rootVC = window.rootViewController else { return }
            
            loadingAlert.show()
            
            self.timer?.invalidate()
            
            DispatchQueue.global(qos: .background).async {
                ImageQueueService.shared.processFirstFromQueue() { imageResponse, imageInfo, code in
                    
                    self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.tryImageQueue), userInfo: nil, repeats: true)
                    
                    guard let imageInfo = imageInfo else { return }
                    guard let code = code else { return }
                    
                    DispatchQueue.main.async {
                        self.loadingAlert.hide() {
                            if (200..<499).contains(code) {
                                if let imageResponse = imageResponse {
                                    rootVC.showAlert(
                                        title: "Успешно обработано измерение от \(imageInfo.date.convertToString())",
                                        message: "SYS: \(imageResponse.sys)\nDIA:\(imageResponse.dia)\nPUL: \(imageResponse.pulse)",
                                        image: nil)
                                } else {
                                    guard let imageData = ImageQueueService.getArrayOfBytesFromImage(imageName: imageInfo.name) else {
                                        rootVC.showAlert(
                                            title: "Ошибка обработки измерения \(imageInfo.date.convertToString())",
                                            message: "Если значения нечитаемые, сделайте фото ещё раз\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
                                            image: nil)
                                        return
                                    }
                                    let image = UIImage(data: Data(imageData))
                                    rootVC.showAlert(
                                        title: "Ошибка обработки измерения \(imageInfo.date.convertToString())",
                                        message: "Если значения нечитаемые, сделайте фото ещё раз\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
                                        image: image)
                                }
                                ImageQueueService.shared.removeFirstFromQueue()
                            }
                        }
                    }
                }
            }
        }
    }}

extension UIViewController {
    func showAlert(title: String, message: String, image: UIImage?, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let image = image {
            let image = UIImageView(image: image)
            alertController.view.addSubview(image)
            image.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: alertController.view, attribute: .centerX, multiplier: 1, constant: 0))
            alertController.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: alertController.view, attribute: .centerY, multiplier: 1, constant: 20))
            alertController.view.addConstraint(NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 225))
            alertController.view.addConstraint(NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300))

        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

private extension UIAlertController {
    func addImage(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60),
            imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -80)
        ])
    }
}


public extension Date {
    func convertToString() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy HH:mm"
        return df.string(from: self)
    }
}
