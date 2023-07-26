import SwiftUI
import SQLite

import SwiftUI
import SQLite

/*
 Define Decimal value to make it storable in sqlite
 **/
extension Decimal: Value {
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

/*
 Define Decimal value to make it storable in sqlite
 **/
extension Color: Value {
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
