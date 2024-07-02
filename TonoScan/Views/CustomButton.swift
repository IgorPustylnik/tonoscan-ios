import UIKit

class CustomButton: UIButton {
    
    enum FontSize {
        case big
        case med
        case small
    }
    
    private var originalTitle: String?
    
    init(title: String, backgroundColor: UIColor, titleColor: UIColor, fontSize: FontSize) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.originalTitle = title // сохраняем оригинальный текст кнопки
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        self.backgroundColor = backgroundColor
        
        let titleColor: UIColor = titleColor
        self.setTitleColor(titleColor, for: .normal)
        
        if backgroundColor == .clear {
            self.setTitleColor(titleColor.moreTransparency(), for: .highlighted)
        }
        
        let highlightedBackgroundColor = backgroundColor.darker() ?? backgroundColor
        if backgroundColor != .clear {
            self.setBackgroundImage(UIImage(color: highlightedBackgroundColor), for: .highlighted)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLoadingIndicator() {
        self.setTitle(nil, for: .normal) // убираем текст
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        self.setTitle(originalTitle, for: .normal)
        self.subviews.forEach { subview in
            if let activityIndicator = subview as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
}

extension UIColor {

    func moreTransparency(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.withAlphaComponent(0.3)
    }

    func darker(by percentage: CGFloat = 10.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

private extension UIImage {
    convenience init(color: UIColor) {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        self.init(ciImage: CIImage(image: image)!)
    }
}
