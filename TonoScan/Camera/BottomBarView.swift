import UIKit

protocol BottomBarDelegate: AnyObject {
    func switchCamera()
    func takePhoto()
}

final class BottomBarView: UIView {
    
    // MARK: - UI Components
    private lazy var captureImageButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 25)), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 36
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setBackgroundImage(UIImage(color: UIColor.black.withAlphaComponent(0.2), size: CGSize(width: 72, height: 72), cornerRadius: 36), for: .highlighted)
        return button
    }()

    private lazy var switchCameraButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 25)), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    weak var delegate: BottomBarDelegate?
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup

    private func setupUI() {
        backgroundColor = UIColor(named: "bottomBarColor")
        
        captureImageButton.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(switchCamera(_:)), for: .touchUpInside)
        
        addSubview(captureImageButton)
        // I decided to get rid of switch camera button as it's not needed
//        addSubview(switchCameraButton)

        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            captureImageButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            captureImageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            captureImageButton.widthAnchor.constraint(equalToConstant: 72),
            captureImageButton.heightAnchor.constraint(equalToConstant: 72),

//            switchCameraButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//            switchCameraButton.centerYAnchor.constraint(equalTo: centerYAnchor),
//            switchCameraButton.widthAnchor.constraint(equalToConstant: 50),
//            switchCameraButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Selectors

    @objc private func captureImage(_ sender: UIButton?) {
        delegate?.takePhoto()
    }

    @objc private func switchCamera(_ sender: UIButton?) {
        delegate?.switchCamera()
    }
}
