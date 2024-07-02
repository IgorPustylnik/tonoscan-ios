import UIKit

// MARK: - Table structs

private struct Section {
    let cells: [ProfileCell]
}

public struct ProfileCell {
    let header: String
    let contents: String
    let handler: (() -> Void)
}

class ProfileController: UIViewController {
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.separatorStyle = .singleLine
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor(named: "tableBackgroundColor")
        tv.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        return tv
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Профиль"
        label.font = UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.heavy)
        return label
    }()
    
    private let buttonEdit: UIButton = {
        let buttonEdit = UIButton()
        buttonEdit.setTitle("Изменить", for: .normal)
        buttonEdit.setTitleColor(.systemBlue, for: .normal)
        return buttonEdit
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTable()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Профиль"
        self.view.backgroundColor = UIColor(named: "tableBackgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        
        let stackView = UIStackView(arrangedSubviews: [label, buttonEdit])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonEdit.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        
        view.addSubview(stackView)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    // MARK: - Table configuration

    fileprivate var models = [Section]()
    
    func configureTable() {
        let pvm = ProfileViewModel.data
        var numbers = ""
        for s in pvm.shared.numbers {
            numbers += s + "\n"
        }
        numbers = String(numbers.dropLast(1))
        models.removeAll()
        models.append(Section(cells: [
            ProfileCell(header: "ID", contents: "\(pvm.shared.id)") {},
            ProfileCell(header: "E-mail", contents: pvm.shared.email) {},
            ProfileCell(header: "Имя пользователя", contents: pvm.shared.name) {},
            ProfileCell(header: "Рассылочные номера", contents: numbers) {},
            ProfileCell(header: "История болезни", contents: pvm.shared.medicalRecordLink) {
                guard let url = URL(string: pvm.shared.medicalRecordLink) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        ]))
        tableView.reloadData()
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return models.count
//    }
    
    // MARK: - Buttons
    
    @objc private func editProfile() {
        let editProfile = EditProfileController()
        self.navigationController?.pushViewController(editProfile, animated: true)
    }
}

// MARK: - TVDataSource

extension ProfileController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].cells[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath)
            as? ProfileTableViewCell else {
                return UITableViewCell()
        }
        cell.configure(with: model)
        return cell
    }
}

// MARK: - TVDelegate

extension ProfileController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.section].cells[indexPath.row]
        model.handler()
    }
}
