import XCTest
import SwiftUI
import SQLite
@testable import Sworm

final class SwormTests: XCTestCase {
    var elem = Element(id: 0, name: "Yanun", value: 25)
    
    func testInsert() throws {
        let db = SQL.setup(isMock: true)
        db.migrate([
            Element.self
        ])
        
        var insertedID: Int64 = 0
        XCTAssertNoThrow(insertedID = try db.insert(elem))
        XCTAssertEqual(1, insertedID)
    }
    
    func testQuery() throws {
        let db = SQL.setup(isMock: true)
        db.migrate([
            Element.self
        ])
    
        var insertedID: Int64 = 0
        XCTAssertNoThrow(insertedID = try db.insert(elem))
        XCTAssertEqual(1, insertedID)
        
        var rows = AnySequence<Row>([])
        XCTAssertNoThrow(rows = try db.query(Element.self, { $0.where(Element.value == 25)}))
        var found = Element(id: 0, name: "", value: 0)
        for row in rows {
            XCTAssertNoThrow(found = try Element.parse(row))
        }
        XCTAssertEqual(elem.name, found.name)
        XCTAssertEqual(elem.value, found.value)
    }
    
    func testHelperDecimal() throws {
        let testCases = [Decimal]([123, 223.445, -8534, -854.6024, -0.0054, 0.0054])
        testCases.forEach { t in
            testHelperDecimalCase(t)
        }
    }
    
    func testHelperDecimalCase(_ d: Decimal) {
        let data = d.datatypeValue
        let decimal = Decimal.fromDatatypeValue(data)
        XCTAssertEqual(decimal, d)
    }
    
    func testHelperColor() throws {
        let testCases = [Color]([.black, .blue, .brown, .red, .init(red: 0.95, green: 0.13, blue: 0.55)])
        testCases.forEach { c in
            testHelperColorCase(c)
        }
    }
    
    func testHelperColorCase(_ c: Color) {
        let data = c.datatypeValue
        let color = Color.fromDatatypeValue(data)
        XCTAssertEqual(c.components!.red.floor(), color.components!.red.floor())
        XCTAssertEqual(c.components!.green.floor(), color.components!.green.floor())
        XCTAssertEqual(c.components!.blue.floor(), color.components!.blue.floor())
        XCTAssertEqual(c.components!.alpha.floor(), color.components!.alpha.floor())
    }
}

extension CGFloat {
    func floor(_ digit: Int = 5) -> CGFloat {
        if digit <= 0 { return self }
        var (up, down) = (CGFloat(1), CGFloat(1))
        for _ in 0 ..< digit {
            up *= 10
            down *= 0.1
        }
        
        return CGFloat(Int(self*up.rounded()-0.5))*down
    }
}

struct Element {
    var id: Int64
    var name: String
    var value: Int
}

extension Element: Migrator {
    static var table: Tablex { Tablex("elements") }
    static var id = Expression<Int64>("id")
    static var name = Expression<String>("name")
    static var value = Expression<Int>("value")
    
    static func migrate(_ conn: Connection) throws {
        try conn.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(name, unique: true)
            t.column(value)
        })
        
        try conn.run(table.createIndex(name, ifNotExists: true))
    }
    
    static func parse(_ r: Row) throws -> Element {
        return Element(
            id: try r.get(id),
            name: try r.get(name),
            value: try r.get(value)
        )
    }
    
    func setter() -> [Setter] {
        return [
            Element.name <- name,
            Element.value <- value
        ]
    }
}
