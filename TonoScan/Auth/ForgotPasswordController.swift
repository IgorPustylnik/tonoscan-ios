import UIKit

class ForgotPasswordController: UIViewController {
    // THIS CONTROLLER WAS ABANDONED AND DOES NOT DO ANYTHING
    
    // MARK: - UI Components
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Восстановить пароль"
        label.font = UIFont.systemFont(ofSize: 27, weight: UIFont.Weight.heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailField = CustomTextField(fieldType: .email)

    private let continueButton = CustomButton(title: "Продолжить", backgroundColor: .systemBlue, titleColor: .white, fontSize: .big)
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        self.continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        
        view.addSubview(label)
        view.addSubview(emailField)
        view.addSubview(continueButton)

        emailField.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            emailField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 22),
            emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 55),
            emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            continueButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 22),
            continueButton.centerXAnchor.constraint(equalTo: emailField.centerXAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 55),
            continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func checkValidity() -> Bool {
        let email = emailField.text ?? ""
        emailField.setValidity(email.isValidEmail())
        return email.isValidEmail()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Selectors
    @objc private func didTapContinue() {
        if !checkValidity() {
            return
        }
//        let email = emailField.text!
           
       }
   
}
