import SwiftUI
import SQLite

extension Decimal: Value {
    public static func fromDatatypeValue(_ datatypeValue: String) -> Decimal {
        return Decimal(string: datatypeValue)!
    }
    
    public var datatypeValue: String {
        self.description
    }
    
    public typealias Datatype = String
    
    public static var declaredDatatype: String {
        return String.declaredDatatype
    }
    
    
}
