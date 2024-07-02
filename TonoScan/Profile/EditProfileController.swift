import UIKit

class EditProfileController: UIViewController {
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .singleLine
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .tableBackground
        tv.register(NumbersTableViewCell.self, forCellReuseIdentifier: NumbersTableViewCell.identifier)
        tv.register(CustomEditTextFieldCell.self, forCellReuseIdentifier: CustomEditTextFieldCell.identifier)
        return tv
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Изменить"
        label.font = UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let logoutButton = CustomButton(title: "Выйти из аккаунта", backgroundColor: .table, titleColor: .systemRed, fontSize: .med)
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = .tableBackground
        
        loadModelInfo()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(didTapSave))
        
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
    
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(label)
        view.addSubview(tableView)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            tableView.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 55),
            logoutButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Table configuration
    
    var numberCells = [NumberCell]()
    var nameModel = String()
    
    func configure() {
        let numbersPvm = ProfileViewModel.data.shared.numbers
        numberCells.removeAll()
        for number in numbersPvm {
            numberCells.append(NumberCell(number: number))
        }
        numberCells.append(NumberCell(number: nil))
        nameModel = ProfileViewModel.data.shared.name
    }
     
    private func loadModelInfo() {
        let name = ProfileViewModel.data.shared.name
        nameModel = name
        tableView.reloadData()
        configure()
    }
    
    private func updateInfo() {
        let loadingAlert = LoadingAlert(message: nil)
        var numbersNew: [String] = []
        for i in 0..<numberCells.count - 1 {
            let num = numberCells[i].number ?? ""
            if num.isValidNumber() {
                let num = num.formatRussianPhoneNumber()
                numbersNew.append(num!)
            } else if num != "" {
                self.showSaveAlert(.incorrectData)
                return
            }
        }
        if !self.nameModel.isValidName() {
            self.showSaveAlert(.incorrectData)
            return
        }
        
        loadingAlert.show()
        DispatchQueue.global(qos: .background).async {
            
            guard let token = UserDataService.shared.getTokenFromMemory() else {
                DispatchQueue.main.async {
                    loadingAlert.hide() { }
                }
                return
            }
            
            RequestService.shared.sendNumbers(with: SendNumbersRequest(token: token, numbers: numbersNew)) { ok, error in
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        loadingAlert.hide() {
                            self.showSaveAlert(.network)
                        }
                    }
                    return
                }
                if !ok {
                    DispatchQueue.main.async {
                        loadingAlert.hide() {
                            self.showSaveAlert(.network)
                        }
                    }
                    return
                }
                
                ProfileViewModel.data.setNumbers(numbersNew)
                ProfileViewModel.data.setName(self.nameModel)
                UserDataService.shared.saveDataToKeychainFromPVM()
                
                DispatchQueue.main.async {
                    loadingAlert.hide() {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    
    // MARK: - Alerts
    
    private enum Error {
        case incorrectData
        case network
    }
    
    private func showSaveAlert(_ error: Error) {
        var title: String
        var message: String
        
        switch (error) {
        case .incorrectData:
            title = "Неверно введены данные"
            message = "Проверьте правильность введённых данных"
        case .network:
            title = "Не удалось сохранить"
            message = "Проблемы с соединением с сервером"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    
        alert.addAction(UIAlertAction(title: "Ок", style:
                                        UIAlertAction.Style.default, handler: {_ in
        }))

        self.present (alert, animated: true, completion: nil)
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(title: "Выход из аккаунта", message: "Вы уверены, что хотите выйти?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Да", style:
                                        UIAlertAction.Style.default, handler: {_ in
            UserDataService.shared.deleteDataFromMemory()
            UserDataService.shared.deleteTokenFromMemory()
            ImageQueueService.shared.deleteImagesFromMemory()
            let nav = UINavigationController(rootViewController: SignInController())
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            print("Logged out")
        }))
        alert.addAction(UIAlertAction(title: "Нет", style:
                                        UIAlertAction.Style.default, handler: {_ in }))

        self.present (alert, animated: true, completion: nil)
    }
    
    // MARK: - Buttons
    @objc private func didTapSave() {
        updateInfo()
    }
    
    @objc private func didTapLogout() {
        showLogoutAlert()
    }
}

// MARK: - NumberCellDelegate

extension EditProfileController: NumberCellDelegate {
    
    func didUpdatePhoneNumber(_ number: String?, at indexPath: IndexPath) {
        numberCells[indexPath.row].number = number
    }
    
    func addNumber(at indexPath: IndexPath) {
        numberCells.removeLast()
        numberCells.append(NumberCell(number: ""))
        numberCells.append(NumberCell(number: nil))
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }

}

// MARK: - TextField Delegate
extension EditProfileController: CustomEditTextFieldCellDelegate {
    
    func updateText(_ text: String) {
        nameModel = text
    }
}

// MARK: - TVDataSource

extension EditProfileController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return numberCells.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let model = numberCells[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NumbersTableViewCell.identifier, for: indexPath)
                    as? NumbersTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.indexPath = indexPath
            cell.configure(with: model)
            return cell
        } else if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomEditTextFieldCell.identifier, for: indexPath)
                    as? CustomEditTextFieldCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.configure(with: .name, and: nameModel)
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - TVDelegate

extension EditProfileController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 30)
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        
        if section == 0 {
            titleLabel.text = "Имя пользователя"
        } else if section == 1 {
            titleLabel.text = "Рассылочные номера"
        }
        
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         guard indexPath.section == 1 else {
             return nil
         }
         guard let _ = numberCells[indexPath.row].number else {
             return nil
         }
         let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (action, view, completionHandler) in
                self?.numberCells.remove(at: indexPath.row)
                 tableView.deleteRows(at: [indexPath], with: .automatic)
                 completionHandler(true)
             }
         deleteAction.backgroundColor = .red
         return UISwipeActionsConfiguration(actions: [deleteAction])
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1 else {
            return
        }
        let model = numberCells[indexPath.row]
        if model.number == nil {
            addNumber(at: indexPath)
        }
    }
}
