import UIKit

class ProfileTableViewCell: UITableViewCell {
    static let identifier = "ProfileTableViewCell"
    
    private let header: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    private let contents: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(named: "tableColor")
        contentView.addSubview(header)
        contentView.addSubview(contents)
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            header.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            contents.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            contents.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            contents.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contents.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure(with model: ProfileCell) {
        header.text = model.header
        contents.text = model.contents
    }
}
   
