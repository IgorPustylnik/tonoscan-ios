import UIKit

class ReceiveCodeController: UIViewController {
    // these strings are here to store the information about the current registration process
    private let name: String
    private let password: String
    private let email: String
    
    // MARK: - UI Components
    
    private let label1: UILabel = {
        let label = UILabel()
        label.text = "Код подтверждения"
        label.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let label2: UILabel = {
        let label = UILabel()
        label.text = "Пожалуйста, введите код, который был отправлен на указанный адрес электронной почты."
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let codeField = CustomTextField(fieldType: .code)

    private let continueButton = CustomButton(title: "Продолжить", backgroundColor: .systemBlue, titleColor: .white, fontSize: .big)
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    init(name: String, password: String, email: String) {
        self.name = name
        self.password = password
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(codeField)
        view.addSubview(continueButton)

        codeField.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: codeField.leadingAnchor),
            label1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            label2.leadingAnchor.constraint(equalTo: codeField.leadingAnchor),
            label2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 20),
            
            codeField.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 22),
            codeField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            codeField.heightAnchor.constraint(equalToConstant: 55),
            codeField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            continueButton.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 22),
            continueButton.centerXAnchor.constraint(equalTo: codeField.centerXAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 55),
            continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Field check
    
    func checkValidity() -> Bool {
        let code = codeField.text ?? ""
        if code.count > 0 {
            codeField.setValidity(true)
            return true
        } else {
            codeField.setValidity(false)
            return false
        }
    }
    
    // MARK: - Buttons
    
    @objc private func didTapContinue() {
        if !checkValidity() {
            return
        }
        let code = codeField.text!
        
        continueButton.showLoadingIndicator()
        
        let confRegRqst = ConfirmRegisterRequest(userFullName: name, password: password, email: email, tempPassword: code)
        
        RequestService.shared.confirmRegister(with: confRegRqst) { ok, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.codeField.setValidity(false)
                    self.continueButton.hideLoadingIndicator()
                    print(error.localizedDescription)
                    return
                }
                self.continueButton.hideLoadingIndicator()
                if !ok {
                    self.codeField.setValidity(false)
                    return
                }
                self.codeField.setValidity(true)
                let vc = SuccessfulRegistrationController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
