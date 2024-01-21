import XCTest
import SwiftUI
import SQLite
@testable import Sworm

final class SwormTests: XCTestCase {
    var elem = Element(id: 0, name: "Yanun", value: 25)
    
    func setupDB() -> DB {
        let db = Sworm.setup(mock: true)
        db.migrate(Element.self)
        return db
    }
    
    func testCRUD() throws {
        let db = setupDB()
    
        var insertedID: Int64 = 0
        XCTAssertNoThrow(insertedID = try db.insert(elem))
        XCTAssertEqual(1, insertedID)
        
        var results = [Element]()
        XCTAssertNoThrow(results = try db.query(Element.self) { $0.where(Element.value == 25) })
        
        XCTAssertEqual(1, results.count)
        guard let found = results.first else { throw XCTestError(.failureWhileWaiting) }
        XCTAssertEqual(elem.name, found.name)
        XCTAssertEqual(elem.value, found.value)
        
        var updatedCount: Int = 0
        let changed = Element(id: insertedID, name: "Update Yanun", value: 30)
        XCTAssertNoThrow(updatedCount = try db.update(changed) { $0.where(Element.id == changed.id )})
        XCTAssertEqual(1, updatedCount)
        
        var result: Element?
        XCTAssertNoThrow(result = try db.query(Element.self) { $0.where(Element.value == 30) }.first)
        XCTAssertNotNil(result)
        
        var upsertID: Int64 = 0
        let upsert = Element(id: 2, name: "Upsert Yanun", value: 50)
        XCTAssertNoThrow(upsertID = try db.upsert(upsert, onConflictOf: Element.id) )
        XCTAssertEqual(2, upsertID)
        
        XCTAssertNoThrow(result = try db.query(Element.self) { $0.where(Element.value == 30) }.first)
        XCTAssertNotNil(result)
        
        var deleteCount: Int = 0
        XCTAssertNoThrow(deleteCount = try db.delete(Element.self) { $0.where(Element.id == found.id) })
        XCTAssertNotEqual(0, deleteCount)
    }
    
    func testDaoCRUD() throws {
        _ = setupDB()
        let dao: BasicRepository = TestDao()
        
        var insertedID: Int64 = 0
        XCTAssertNoThrow(insertedID = try dao.insert(elem))
        XCTAssertEqual(1, insertedID)
        
        var results = [Element]()
        XCTAssertNoThrow(results = try dao.query(Element.self) { $0.where(Element.value == 25) })
        
        XCTAssertEqual(1, results.count)
        guard let found = results.first else { throw XCTestError(.failureWhileWaiting) }
        XCTAssertEqual(elem.name, found.name)
        XCTAssertEqual(elem.value, found.value)
        
        var updatedCount: Int = 0
        let changed = Element(id: insertedID, name: "Update Yanun", value: 30)
        XCTAssertNoThrow(updatedCount = try dao.update(changed) { $0.where(Element.id == changed.id )})
        XCTAssertEqual(1, updatedCount)
        
        var result: Element?
        XCTAssertNoThrow(result = try dao.query(Element.self) { $0.where(Element.value == 30) }.first)
        XCTAssertNotNil(result)
        
        var upsertID: Int64 = 0
        let upsert = Element(id: 2, name: "Upsert Yanun", value: 50)
        XCTAssertNoThrow(upsertID = try dao.upsert(upsert, onConflictOf: Element.id) )
        XCTAssertEqual(2, upsertID)
        
        XCTAssertNoThrow(result = try dao.query(Element.self) { $0.where(Element.value == 30) }.first)
        XCTAssertNotNil(result)
        
        var deleteCount: Int = 0
        XCTAssertNoThrow(deleteCount = try dao.delete(Element.self) { $0.where(Element.id == found.id) })
        XCTAssertNotEqual(0, deleteCount)
    }
    
    func testDaoCRUDWithErrorReturn() throws {
        _ = setupDB()
        let dao: BasicRepository = TestDao()
        
        var insertedID: Int64 = 0
        var error: Error? = nil
        XCTAssertNoThrow((insertedID, error) = dao.insert(elem))
        XCTAssertNil(error)
        XCTAssertEqual(1, insertedID)
        
        var results = [Element]()
        XCTAssertNoThrow((results, error) = dao.query(Element.self) { $0.where(Element.value == 25) })
        XCTAssertNil(error)
        
        XCTAssertEqual(1, results.count)
        guard let found = results.first else { throw XCTestError(.failureWhileWaiting) }
        XCTAssertEqual(elem.name, found.name)
        XCTAssertEqual(elem.value, found.value)
        
        var updatedCount: Int = 0
        let changed = Element(id: insertedID, name: "Update Yanun", value: 30)
        XCTAssertNoThrow((updatedCount, error) = dao.update(changed) { $0.where(Element.id == changed.id )})
        XCTAssertNil(error)
        XCTAssertEqual(1, updatedCount)
        
        XCTAssertNoThrow((results, error) = dao.query(Element.self) { $0.where(Element.value == 30) })
        XCTAssertNil(error)
        XCTAssertEqual(1, results.count)
        
        var upsertID: Int64 = 0
        let upsert = Element(id: 2, name: "Upsert Yanun", value: 50)
        XCTAssertNoThrow((upsertID, error) = dao.upsert(upsert, onConflictOf: Element.id) )
        XCTAssertNil(error)
        XCTAssertEqual(2, upsertID)
        
        XCTAssertNoThrow((results, error) = dao.query(Element.self) { $0.where(Element.value == 30) })
        XCTAssertNil(error)
        XCTAssertEqual(1, results.count)
        
        var deleteCount: Int = 0
        XCTAssertNoThrow((deleteCount, error) = dao.delete(Element.self) { $0.where(Element.id == found.id) })
        XCTAssertNil(error)
        XCTAssertNotEqual(0, deleteCount)
    }
    
    func testHelperDecimal() throws {
        let testCases = [Decimal]([123, 223.445, -8534, -854.6024, -0.0054, 0.0054])
        try testCases.forEach { t in
            try testHelperDecimalCase(t)
        }
    }
    
    func testHelperDecimalCase(_ d: Decimal) throws {
        let data = d.datatypeValue
        let decimal = Decimal.fromDatatypeValue(data)
        XCTAssertEqual(decimal, d)
    }
    
    func testHelperColor() throws {
        let testCases = [Color]([.black, .blue, .brown, .red, .init(red: 0.95, green: 0.13, blue: 0.55)])
        try testCases.forEach { c in
            try testHelperColorCase(c)
        }
    }
    
    func testHelperColorCase(_ c: Color) throws {
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

extension Element: Model {
    static let tableName: String = "elements"
    static var id = Expression<Int64>("id")
    static var name = Expression<String>("name")
    static var value = Expression<Int>("value")
    
    static func migrate(_ conn: DB) throws {
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

struct TestDao: BasicDao {}
extension TestDao: BasicRepository {}
