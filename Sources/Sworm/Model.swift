import Foundation
import SQLite

public typealias UUID = Foundation.UUID
public typealias Tablex = SQLite.Table
public typealias Expression = SQLite.Expression

public protocol PrimaryKeyTypeProtocol {}
extension Int: PrimaryKeyTypeProtocol {}
extension Int32: PrimaryKeyTypeProtocol {}
extension Int64: PrimaryKeyTypeProtocol {}
extension UUID: PrimaryKeyTypeProtocol {}

// MARK: Model
/**
 define for migrate table in sqlite
 ```
 // Sample
 extension Element: Model {
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let value = Expression<Blob>("value")
    
    static let tableName: String = "elements"
    
    static func migrate(_ db: DB) throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(name, unique: true)
            t.column(value)
        })
        
        try db.run(table.createIndex(name, ifNotExists: true))
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
 
 ```
 */
public protocol Model {
    associatedtype PrimaryKey: PrimaryKeyTypeProtocol
    
    static var id: Expression<PrimaryKey> { get }

    static var tableName: String { get }
    
    /**
     migrate sqlite datebase schema
     ```
     // Sample
     static func migrate(_ db: DB) throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(name, unique: true)
            t.column(value)
        })
        try db.run(table.createIndex(name, ifNotExists: true))
     }
     ```
     */
    static func migrate(_:DB) throws
    
    /**
     parse object from result row
     ```
     // Sample
     static func parse(_ r: Row) throws -> Element {
        return Element(
            id: try r.get(id),
            name: try r.get(name),
            value: try r.get(value)
        )
     }
     ```
     */
    static func parse(_:Row) throws -> Self
    
    /**
     primaryKeySetter for insert, update, upsert function.
     - Note: return nil if primary key is auto incremented.
     ```
     // Sample
     static func primaryKeySetter() -> Setter? {
        return Element.id <- id
     }
     ```
     */

    func primaryKeySetter() -> Setter?
    
    /**
     valuesSetter for insert, update, upsert function
     - Note: DO NOT set primary key in setter.
     ```
     // Sample
     static func valuesSetter() -> [Setter] {
        return [
            Element.name <- name,
            Element.value<- value
        ]
     }
     ```
     */
    func valuesSetter() -> [Setter]
}

extension Model {
    public static var table: Tablex { .init(tableName) }
    
    func get(_ setter: [Setter], primaryKey: Bool = false) -> [Setter] {
        var pk: Setter? = nil
        if primaryKey {
            pk = primaryKeySetter()
        }

        if setter.isEmpty {
            return self.valuesSetter().optionalAppended(pk)
        }

        for s in setter {
            if s == pk {
                return setter
            }
        }
        
        return setter.optionalAppended(pk)
    }
}


fileprivate extension RangeReplaceableCollection {
    func appended(_ newElement: Element) -> Self {
        var slice = self
        slice.append(newElement)
        return slice
    }

    func optionalAppended(_ newElement: Element?) -> Self {
        guard let newElement = newElement else {
            return self
        }

        return self.appended(newElement)
    }
}
