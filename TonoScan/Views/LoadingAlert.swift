import UIKit

class LoadingAlert {
    private var alertController: UIAlertController?
    private var message: String
    private var hasMessage: Bool
    
    init(message: String?) {
        if let message = message {
            self.message = message + "\n\n"
            self.hasMessage = true
        } else {
            self.message = "\n"
            self.hasMessage = false
        }
    }
    
    func show() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
           guard let controller = window.rootViewController else {
               return
           }
           show(on: controller)
       }
    
    private func show(on controller: UIViewController) {
        alertController = UIAlertController(title: "Пожалуйста, подождите", message: message, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        alertController?.view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: alertController!.view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: alertController!.view.centerYAnchor, constant: (hasMessage) ? 30 : 20)
        ])
        
        controller.present(alertController!, animated: true, completion: nil)
    }
    
    func hide(completion: (() -> Void)?) {
        alertController?.dismiss(animated: true) { completion?()
        }
        alertController = nil
    }
}
