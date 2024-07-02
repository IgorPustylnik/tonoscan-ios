import AVFoundation
import UIKit

class CameraService: NSObject {
    private var captureDevice: AVCaptureDevice?
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?

    private var backInput: AVCaptureInput!
    private var frontInput: AVCaptureInput!
    private let cameraQueue = DispatchQueue(label: "com.igorpustylnik.TonoScan")

    private var backCameraOn = true
    
    override init() {
        super.init()
        checkPermissions()
        setupInputs()
    }
    
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    
    private func setupInputs() {

        backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)

        guard let backCamera = backCamera,
              let frontCamera = frontCamera
        else {
            return
        }

        do {
            backInput = try AVCaptureDeviceInput(device: backCamera)

            guard captureSession.canAddInput(backInput) else {
                return
            }

            frontInput = try AVCaptureDeviceInput(device: frontCamera)

            guard captureSession.canAddInput(frontInput) else {
                return
            }
        } catch {
            fatalError("could not connect camera")
        }

        captureDevice = backCamera
            captureSession.addInput(backInput)

     }
    
    private func setupOutput() {
      guard captureSession.canAddOutput(photoOutput) else {
          return
      }

      photoOutput.isHighResolutionCaptureEnabled = true
      photoOutput.maxPhotoQualityPrioritization = .balanced
      captureSession.addOutput(photoOutput)
    }
    
    func setupAndStartCaptureSession() {
      cameraQueue.async { [weak self] in
          self?.captureSession.beginConfiguration()
          if let canSetSessionPreset = self?.captureSession.canSetSessionPreset(.photo), canSetSessionPreset {
              self?.captureSession.sessionPreset = .photo
          }
          self?.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true

          self?.setupOutput()

          self?.captureSession.commitConfiguration()
          self?.captureSession.startRunning()
        }
    }
    
    func switchCameraInput() {
        captureSession.beginConfiguration()
        if backCameraOn {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            captureDevice = frontCamera
            backCameraOn = false
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            captureDevice = backCamera
            backCameraOn = true
        }

        photoOutput.connections.first?.videoOrientation = .portrait
        photoOutput.connections.first?.isVideoMirrored = !backCameraOn
        captureSession.commitConfiguration()
    }

    private func checkPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            return
        case .denied:
            abort()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
                                            { (authorized) in
                if(!authorized){
                    abort()
                }
            })
        case .restricted:
            abort()
        @unknown default:
            fatalError()
        }
    }
    
    func takePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}


extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Failed to capture photo: \(String(describing: error))")
            return
        }
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        DispatchQueue.main.async {
            if let image = UIImage(data: imageData) {
                if let compressedData = image.jpegData(compressionQuality: 0.25) {
                    if let imageName = self.saveImageToDisk(imageData: compressedData)?.lastPathComponent {
                        ImageQueueService.shared.addToQueue(imageInfo:
                                                        ImageInfo(name: imageName,
                                                                  date: Date()))
                        ImageQueueService.shared.tryImageQueue()
                    }
                }
            }
        }
    }
    
    private func saveImageToDisk(imageData: Data) -> URL? {
        do {
            let fileManager = FileManager.default
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsURL.appendingPathComponent("\(UUID().uuidString).jpg")
            try imageData.write(to: fileURL)
            print("Saved image to \(fileURL)")
            return fileURL
        } catch {
            print("Error saving image to disk: \(error)")
            return nil
        }
    }
}
