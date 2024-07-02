import UIKit

class RegisterController: UIViewController {
    
    // MARK: - UI Components
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Регистрация"
        label.font = UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameField = CustomTextField(fieldType: .name)
    private let emailField = CustomTextField(fieldType: .email)
    private let passwordField = CustomTextField(fieldType: .password)
    
    private let registerButton = CustomButton(title: "Зарегистрироваться", backgroundColor: .systemBlue, titleColor: .white, fontSize: .big)
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        self.registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(registerButton)
        view.addSubview(label)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Регистрация", style: .plain, target: nil, action: nil)
        
        nameField.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            nameField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            nameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameField.heightAnchor.constraint(equalToConstant: 55),
            nameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 22),
            emailField.centerXAnchor.constraint(equalTo: nameField.centerXAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 55),
            emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 22),
            passwordField.centerXAnchor.constraint(equalTo: nameField.centerXAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 55),
            passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            registerButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 22),
            registerButton.centerXAnchor.constraint(equalTo: nameField.centerXAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 55),
            registerButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Fields checks
    
    func checkValidity() -> Bool {
        var flag = true
        let name = nameField.text ?? ""
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        if name.count < 1 {
            nameField.setValidity(false)
            flag = false
        } else {
            nameField.setValidity(true)
        }
        if !email.isValidEmail() {
            emailField.setValidity(false)
            flag = false
        } else {
            emailField.setValidity(true)
        }
        if !password.isValidPassword() {
            passwordField.setValidity(false)
            flag = false
        } else {
            passwordField.setValidity(true)
        }
        return flag
    }

    private func showWrongCredentialsAlert() {
        let alert = UIAlertController(title: "Неверные данные", message: "Возможно, вы уже зарегистрированы", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ок", style:
                                        UIAlertAction.Style.default, handler: {_ in
            print("нажали ок после неправильно введённых данных")
        }))

        self.present (alert, animated: true, completion: nil)
    }
    
    // MARK: - Buttons
    @objc private func didTapRegister() {
        if !checkValidity() {
            return
        }
        
        registerButton.showLoadingIndicator()
        
        let name = nameField.text!
        let password = passwordField.text!
        let email = emailField.text!
        
        let regUsrRqst = RegisterRequest(userFullName: name, password: password, email: email)
        RequestService.shared.tempRegister(with: regUsrRqst) { [weak self] ok, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.registerButton.hideLoadingIndicator()
                    self?.showWrongCredentialsAlert()
                    print(error.localizedDescription)
                    return
                } else if !ok {
                    self?.registerButton.hideLoadingIndicator()
                    self?.showWrongCredentialsAlert()
                    return
                }
                self?.registerButton.hideLoadingIndicator()
                let vc = ReceiveCodeController(name: name, password: password, email: email)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
