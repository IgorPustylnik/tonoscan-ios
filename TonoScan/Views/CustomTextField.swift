import UIKit

class CustomTextField: UITextField {
    
    private let authFieldType: CustomTextFieldType
    private let errorLabel: UILabel
    
    init(fieldType: CustomTextFieldType) {
        self.authFieldType = fieldType
        self.errorLabel = UILabel()
        super.init(frame: .zero)
        
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 10
        
        self.returnKeyType = .done
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        
        self.leftViewMode = .always
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        
        switch fieldType {
        case .name:
            self.placeholder = "Имя пользователя"
            self.errorLabel.text = "Неверное имя пользователя"
        case .email:
            self.placeholder = "Адрес электронной почты"
            self.errorLabel.text = "Неверный адрес электронной почты"
            self.keyboardType = .emailAddress
            self.textContentType = .emailAddress
        case .password:
            self.placeholder = "Пароль"
            self.errorLabel.text = "Некорректный пароль"
            self.keyboardType = .asciiCapable
            self.textContentType = .oneTimeCode
            self.isSecureTextEntry = true
        case .code:
            self.placeholder = "Код"
            self.errorLabel.text = "Неверный код"
            self.keyboardType = .numberPad
        }
        
        errorLabel.textColor = .systemRed
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            errorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        errorLabel.isHidden = true
    }
    
    func setValidity(_ valid: Bool) {
        if valid {
            self.layer.borderWidth = 0
            errorLabel.isHidden = true
        } else {
            self.layer.borderColor = UIColor.systemRed.cgColor
            self.layer.borderWidth = 1
            errorLabel.isHidden = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
