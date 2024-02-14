import SQLite

public typealias Tablex = SQLite.Table

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
     setter for insert, update, upsert function
     - Note: DO NOT set primary key in setter.
     ```
     // Sample
     static func setter() -> [Setter] {
        return [
            Element.name <- name,
            Element.value<- value
        ]
     }
     ```
     */
    func setter() -> [Setter]
}

extension Model {
    public static var table: Tablex { .init(tableName) }
    
    func get(_ setter: [Setter], primaryKey: Setter? = nil) -> [Setter] {
        if setter.isEmpty {
            return self.setter().optionalAppended(primaryKey)
        }
        return setter.optionalAppended(primaryKey)
    }
}


fileprivate extension RangeReplaceableCollection {
    func optionalAppended(_ newElement: Element?) -> Self {
        guard let newElement = newElement else {
            return self
        }
        
        var slice = self
        slice.append(newElement)
        return slice
    }
}
