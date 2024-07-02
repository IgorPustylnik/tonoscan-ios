import Foundation
import UIKit

class AddNumbersController: UIViewController {
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .singleLine
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor(named: "tableBackgroundColor")
        tv.register(NumbersTableViewCell.self, forCellReuseIdentifier: NumbersTableViewCell.identifier)
        return tv
    }()
    
    private lazy var label1: UILabel = {
        let label1 = UILabel()
        label1.text = "Номера для рассылки"
        label1.numberOfLines = 0
        label1.font = UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.heavy)
        return label1
    }()
    
    private lazy var label2: UILabel = {
        let label2 = UILabel()
        label2.text = "Это нужно для того, чтобы ваши родственники своевременно получали информацию об измерениях"
        label2.numberOfLines = 0
        label2.textColor = .secondaryLabel
        label2.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.light)
        label2.translatesAutoresizingMaskIntoConstraints = false
        return label2
    }()
    
    private lazy var skipButton: CustomButton = {
        let skipButton = CustomButton(title: "Пропустить", backgroundColor: .clear, titleColor: .systemBlue, fontSize: .med)
        skipButton.addTarget(self, action: #selector(skip), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        return skipButton
    }()
    
    private lazy var saveButton: CustomButton = {
        let saveButton = CustomButton(title: "Сохранить", backgroundColor: .systemBlue, titleColor: .white, fontSize: .med)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        return saveButton
    }()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        configureTable()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Номера для рассылки"
        self.view.backgroundColor = UIColor(named: "tableBackgroundColor")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let stackView = UIStackView(arrangedSubviews: [label1, skipButton])
        stackView.axis = .horizontal
        stackView.spacing = 1
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(label2)
        view.addSubview(saveButton)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            label2.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            label2.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            label2.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 55),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: Table configuration

    fileprivate var cells = [NumberCell]()
    
    func configureTable() {
        let numbersPvm = ProfileViewModel.data.shared.numbers
        cells.removeAll()
        for number in numbersPvm {
            cells.append(NumberCell(number: number))
        }
        cells.append(NumberCell(number: nil))
        tableView.reloadData()
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Buttons
    
    @objc private func save(_ sender: UIButton?) {
        let loadingAlert = LoadingAlert(message: nil)
        var numbersNew: [String] = []
        for i in 0..<cells.count - 1 {
            let num = cells[i].number ?? ""
            if num.isValidNumber() {
                let num = num.formatRussianPhoneNumber()
                numbersNew.append(num!)
            } else if num != "" {
                self.showSaveAlert(.incorrectData)
                return
            }
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
                UserDataService.shared.saveDataToKeychainFromPVM()
                
                DispatchQueue.main.async {
                    loadingAlert.hide() {
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
    
    @objc private func skip() {
        let vc = TabBarController()
        vc.modalPresentationStyle = .fullScreen
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = vc
        window.makeKeyAndVisible()
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
}

// MARK: - NumberCellDelegate

extension AddNumbersController: NumberCellDelegate {
    func didUpdatePhoneNumber(_ number: String?, at indexPath: IndexPath) {
        self.cells[indexPath.row].number = number
    }
    
    func addNumber(at indexPath: IndexPath) {
        let newIndexPath = IndexPath(row: cells.count - 1, section: 0)
        cells.removeLast()
        cells.append(NumberCell(number: ""))
        cells.append(NumberCell(number: nil))
        self.tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
}

// MARK: - TVDataSource

extension AddNumbersController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = cells[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NumbersTableViewCell.identifier, for: indexPath)
            as? NumbersTableViewCell else {
                return UITableViewCell()
        }
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configure(with: model)
        return cell
    }
}

// MARK: - TVDelegate
extension AddNumbersController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let _ = self.cells[indexPath.row].number else {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (action, view, completionHandler) in
            self?.cells.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = cells[indexPath.row]
        if model.number == nil {
            addNumber(at: indexPath)
        }
    }
    
}
