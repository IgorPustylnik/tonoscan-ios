import Foundation

public extension String {
    func isValidEmail() -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        return !NSPredicate(format: "SELF MATCHES %@", ".*[а-яА-ЯёЁ].*").evaluate(with: self) && self.count >= 8
    }
    
    func isValidName() -> Bool {
        return self.count > 0
    }
    
    func isValidNumber() -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "^((\\+7|8)+([0-9]){10})$").evaluate(with: self)
    }
    
    func isValidCode() -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "^\\d{6}$").evaluate(with: self)
    }
    
    func formatRussianPhoneNumber() -> String? {
        let digits = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard digits.count == 11 else {
            return nil
        }
        let formattedNumber = "+7" + digits.dropFirst()
        return formattedNumber
    }
    
    func formatPhoneNumberWithSpacesAndBrackets() -> String? {
        guard self.count == 11 else {
            return nil
        }
        let formattedNumber = String(format: "+7 (%@) %@-%@-%@",
                                     String(self.prefix(3)),
                                     String(self.dropFirst(3).prefix(3)),
                                     String(self.dropFirst(6).prefix(2)),
                                     String(self.dropFirst(8)))

        return formattedNumber
    }
}
