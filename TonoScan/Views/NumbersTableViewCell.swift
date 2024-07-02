import UIKit

struct NumberCell {
    var number: String?
}

protocol NumberCellDelegate: AnyObject {
    func didUpdatePhoneNumber(_ phoneNumber: String?, at indexPath: IndexPath)
    func addNumber(at indexPath: IndexPath)
}

class NumbersTableViewCell: UITableViewCell {
    static let identifier = "NumbersTableViewCell"
    weak var delegate: NumberCellDelegate?
    var indexPath: IndexPath?
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.text = "добавить номер"
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
    }
    
    private let field: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.frame = .zero
        
        field.returnKeyType = .done
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        
        field.placeholder = "Номер телефона"
        field.font = .systemFont(ofSize: 15, weight: .light)
        field.keyboardType = .phonePad
        
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
    
    public func configure(with model: NumberCell) {
        if let number = model.number {
            contentView.addSubview(field)
            field.text = number
            field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            NSLayoutConstraint.activate([
                field.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                field.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                field.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                field.heightAnchor.constraint(equalTo: contentView.heightAnchor)
            ])
        } else {
            let btn = UIButton()
            btn.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(btn)
            
            NSLayoutConstraint.activate([
                btn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
                btn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                btn.heightAnchor.constraint(equalToConstant: 20),
                btn.widthAnchor.constraint(equalToConstant: 20)
            ])
            contentView.addSubview(label)
            btn.setBackgroundImage(UIImage(systemName: "plus.circle.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
            btn.addTarget(self, action: #selector(addNumber), for: .touchUpInside)
            btn.tintColor = .systemGreen
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: btn.trailingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        }
    }
    
    @objc private func addNumber(_ sender: UIButton) {
        guard let indexPath = indexPath else {
            return
        }
        self.delegate?.addNumber(at: indexPath)
    }
    
    @objc private func deleteCell(_ sender: UIButton) {
        print("tapped delete cell")
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let indexPath = indexPath else {
            return
        }
        delegate?.didUpdatePhoneNumber(textField.text, at: indexPath)
    }
}
