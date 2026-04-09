import Foundation

extension Decimal {
    /// Formats as Danish Krone: "12,95 kr."
    var asDKK: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "DKK"
        formatter.currencySymbol = "kr."
        formatter.locale = Locale(identifier: "da_DK")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self) kr."
    }

    /// Formats as a plain number with Danish locale: "12,95"
    var asDanishNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "da_DK")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
    }
}
