import UIKit

class SignInController: UIViewController {
    
    // MARK: - UI Components
    private let headerView = AuthHeaderView(title: "TonoScan", subTitle: "Войдите в свой аккаунт")
    
    private let emailField = CustomTextField(fieldType: .email)
    private let passwordField = CustomTextField(fieldType: .password)
    
    private let signInButton = CustomButton(title: "Войти", backgroundColor: .systemBlue, titleColor: .white, fontSize: .big)
    private let newUserButton = CustomButton(title: "Зарегистрируйтесь", backgroundColor: .clear, titleColor: .systemBlue, fontSize: .med)
    //    private let forgotPasswordButton = CustomButton(title: "Забыли пароль?", backgroundColor: .systemBackground, titleColor: .systemBlue, fontSize: .small)
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        self.signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        self.newUserButton.addTarget(self, action: #selector(didTapNewUser), for: .touchUpInside)
        //        self.forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Вход", style: .plain, target: nil, action: nil)
        
        self.view.addSubview(headerView)
        self.view.addSubview(emailField)
        self.view.addSubview(passwordField)
        self.view.addSubview(signInButton)
        self.view.addSubview(newUserButton)
        //        self.view.addSubview(forgotPasswordButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        newUserButton.translatesAutoresizingMaskIntoConstraints = false
        //        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.headerView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 222),
            
            self.emailField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            self.emailField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.emailField.heightAnchor.constraint(equalToConstant: 55),
            self.emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 22),
            self.passwordField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.passwordField.heightAnchor.constraint(equalToConstant: 55),
            self.passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.signInButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 22),
            self.signInButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.signInButton.heightAnchor.constraint(equalToConstant: 55),
            self.signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.newUserButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 11),
            self.newUserButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.newUserButton.heightAnchor.constraint(equalToConstant: 44),
            self.newUserButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            //            self.forgotPasswordButton.topAnchor.constraint(equalTo: newUserButton.bottomAnchor, constant: 6),
            //            self.forgotPasswordButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            //            self.forgotPasswordButton.heightAnchor.constraint(equalToConstant: 44),
            //            self.forgotPasswordButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Fields checks
    
    func checkValidity() -> Bool {
        var flag = true
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
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
        let alert = UIAlertController(title: "Неверный логин или пароль", message: "Проверьте правильность введённых данных", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ок", style:
                                        UIAlertAction.Style.default, handler: {_ in
            print("нажали ок после неправильно введённых данных")
        }))
        
        self.present (alert, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Buttons
    @objc private func didTapSignIn() {
        if !checkValidity() {
            return
        }
        let password = passwordField.text!
        let email = emailField.text!

        let loginRequest = SignInRequest(email: email, password: password)
        signInButton.showLoadingIndicator()
        
        DispatchQueue.global(qos: .background).async {
            RequestService.shared.signIn(with: loginRequest) { [weak self] token, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.signInButton.hideLoadingIndicator()
                        self?.showWrongCredentialsAlert()
                        print(error.localizedDescription)
                    } else {
                        guard let token = token else {
                            print("failed to login (token response empty")
                            self?.signInButton.hideLoadingIndicator()
                            self?.showWrongCredentialsAlert()
                            return
                        }
                        UserDataService.shared.saveTokenToMemory(token: token)
                        UserDataService.shared.loadDataFromServerToMemory() {
                            DispatchQueue.main.async {
                                self?.signInButton.hideLoadingIndicator()
                                if let userData = KeychainService.shared.getUserData() {
                                    if userData.relativesPhoneNumber.isEmpty {
                                        let vc = AddNumbersController()
                                        vc.modalPresentationStyle = .fullScreen
                                        guard let window = UIApplication.shared.windows.first else { return }
                                        window.rootViewController = vc
                                        window.makeKeyAndVisible()
                                    } else {
                                        let vc = TabBarController()
                                        vc.modalPresentationStyle = .fullScreen
                                        guard let window = UIApplication.shared.windows.first else { return }
                                        window.rootViewController = vc
                                        window.makeKeyAndVisible()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func didTapNewUser() {
        let vc = RegisterController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapForgotPassword() {
        let vc = ForgotPasswordController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
