import UIKit

protocol CustomEditTextFieldCellDelegate: AnyObject {
    func updateText(_ text: String)
}

class CustomEditTextFieldCell: UITableViewCell {
    static let identifier = "EditTextFieldCell"
    weak var delegate: CustomEditTextFieldCellDelegate?
    private var title: String?
    
    private let field: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.frame = .zero
        
        field.returnKeyType = .done
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        
        field.font = .systemFont(ofSize: 15, weight: .light)
        return field
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(named: "tableColor")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with fieldType: CustomTextFieldType, and text: String?) {
        contentView.addSubview(field)
        field.text = text
        field.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        switch fieldType {
        case .name:
            field.placeholder = "Имя пользователя"
        case .email:
            field.placeholder = "Адрес электронной почты"
            field.keyboardType = .emailAddress
            field.textContentType = .emailAddress
        case .password:
            field.placeholder = "Пароль"
            field.textContentType = .oneTimeCode
            field.isSecureTextEntry = true
        case .code:
            field.placeholder = "Код"
            field.keyboardType = .numberPad
        }
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            field.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            field.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            field.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }
    
    @objc private func textFieldDidChange() {
//        print(field.text)
        delegate?.updateText(field.text ?? "")
    }
}
