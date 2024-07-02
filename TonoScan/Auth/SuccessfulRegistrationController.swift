import UIKit

class SuccessfulRegistrationController: UIViewController {

    // MARK: - UI Components
    
    private let successLabel: UILabel = {
        let label = UILabel()
        label.text = "Вы успешно зарегистрировались!"
        label.font = UIFont.systemFont(ofSize: 27, weight: UIFont.Weight.heavy)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Теперь вам нужно будет выполнить вход в свою учётную запись"
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let continueButton = CustomButton(title: "Ок", backgroundColor: .systemBlue, titleColor: .white, fontSize: .med)
    
    // MARK: - Lifecycle
    
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
        
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(successLabel)
        view.addSubview(instructionLabel)
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            successLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            successLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            successLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -40),
            
            instructionLabel.leadingAnchor.constraint(equalTo: successLabel.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: successLabel.trailingAnchor, constant: -20),
            instructionLabel.topAnchor.constraint(equalTo: successLabel.bottomAnchor, constant: 10),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            continueButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 55),
            continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
    }
    
    // MARK: - Selectors
    
    @objc private func didTapContinue() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
