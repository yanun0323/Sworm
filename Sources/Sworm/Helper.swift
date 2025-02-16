import SwiftUI
import SQLite

public typealias Value  = SQLite.Value

// MARK: Decimal
/** define decimal value to make it storable in sqlite **/
extension Decimal: @retroactive Expressible {}
extension Decimal: @retroactive Value {
    public typealias Datatype = String
    
    public static var declaredDatatype: String {
        return String.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ datatypeValue: String) -> Decimal {
        return Decimal(string: datatypeValue)!
    }
    
    public var datatypeValue: String {
        return self.description
    }
}

// MARK: Color
/** define color value to make it storable in sqlite **/
extension Color: @retroactive Expressible {}
extension Color: @retroactive Value {
    public typealias Datatype = Blob
    
    public static var declaredDatatype: String {
        return Data.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ datatypeValue: Blob) -> Color {
        return try! JSONDecoder().decode(Color.self, from: Data(datatypeValue.bytes))
    }
    
    public var datatypeValue: Blob {
        return try! JSONEncoder().encode(self).datatypeValue
    }
}
