import UIKit
import AVFoundation

class CameraController: UIViewController {
    private lazy var screen = UIScreen.main.bounds
    private lazy var bottomBar = BottomBarView()
    private var cameraService: CameraService
    
    // MARK: - Lifecycle
    
    init(cameraService: CameraService) {
        self.cameraService = cameraService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupPreviewLayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraService.captureSession.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraService.setupAndStartCaptureSession()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Камера"
        view.backgroundColor = .systemBackground
        
        bottomBar.delegate = self
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 90),
        ])
    }
    
    // MARK: - Preview layer view (kostyli)

    private func setupPreviewLayer() {
        let previewWidth = screen.width
        let previewHeight = (previewWidth / 3) * 4
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraService.captureSession)
        previewLayer.frame = CGRect(x: 0, y: view.bounds.height - view.safeAreaInsets.bottom - previewHeight - 90, width: previewWidth, height: previewHeight)
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
    }
}

// MARK: - BottomBarDelegate

extension CameraController: BottomBarDelegate {

    func switchCamera() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        cameraService.switchCameraInput()
    }

    func takePhoto() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        
        cameraService.photoOutput.capturePhoto(with: photoSettings, delegate: cameraService)
        if !Reachability.isConnectedToNetwork() {
            self.showAlert(
                title: "Нет интернет соединения",
                message: "Фото будет отправлено, как только оно появится", image: nil)
        }
    }
}
