import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
       var captureSession: AVCaptureSession?
       var videoPreviewLayer: AVCaptureVideoPreviewLayer?

       override func viewDidLoad() {
           super.viewDidLoad()
           checkCameraAuthorization()
       }

       func checkCameraAuthorization() {
           // Проверка авторизации камеры...
       }

       func setupCamera() {
           captureSession = AVCaptureSession()

           guard let captureSession = captureSession else { return }

           guard let backCamera = AVCaptureDevice.default(for: .video) else { return }

           do {
               let input = try AVCaptureDeviceInput(device: backCamera)
               
               if captureSession.canAddInput(input) {
                   captureSession.addInput(input)

                   videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                   videoPreviewLayer?.videoGravity = .resizeAspectFill
                   videoPreviewLayer?.frame = cameraView.bounds
                   cameraView.layer.addSublayer(videoPreviewLayer!)

                   captureSession.startRunning()
               }
           } catch let error {
               print("Error: \(error)")
           }
       }
    
    @IBAction func openCameraPressed(_ sender: Any) {
        setupCamera()
    }
}
