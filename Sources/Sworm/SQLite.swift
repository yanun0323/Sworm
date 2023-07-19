import SQLite
import SwiftUI

public typealias Tablex = SQLite.Table

// MARK: SQLite Instance
/**
 Property Wrapper for SQLite instance
 
 ```
 // initial the SQL before use it
 let db = SQL.setup(dbName: "database", isMock: false) /* use in memory sqlite database if isMock is true*/
 // get db
 let db = SQL.getDriver()
 ```
 */
public struct SQL {
    private static var db: Connection? = nil
}

extension SQL {
    /** Get sqlite database instance. if no exist, create a in memory sqlite database  connection */
    public static func getDriver() -> Connection {
        if let conn = db {
            return conn
        }
        return self.setup(isMock: true)
    }
    /** Create a new sqlite database instance, use in memory sqlite database if isMock is true */
    public static func setup(dbName name: String? = nil, isMock: Bool) -> Connection {
        var dbName = "production"
        if let name = name, !name.isEmpty {
            dbName = name
        }
        let conn: Connection
        if isMock && (name == nil || name!.isEmpty) {
            conn = try! Connection(.inMemory)
        } else {
            conn = try! Connection(filePath(dbName))
        }
        conn.busyTimeout = 5
        
        db = conn
        return db!
    }
    
    private static func filePath(_ filename: String) -> String {
        // set the path corresponding to application support
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
        ).first! + "/" + Bundle.main.bundleIdentifier!
        
        // create parent directory inside application support if it doesn’t exist
        try! FileManager.default.createDirectory(
            atPath: path, withIntermediateDirectories: true, attributes: nil
        )
        
        #if DEBUG
        print(path)
        #endif
        
        return "\(path)/\(filename).sqlite3"
    }
}

// MARK: Migrator
/**
 define for migrate table in sqlite
 ```
 // Sample
 extension Element: Migrator {
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let value = Expression<Blob>("value")
    
    static var table: Tablex { .init("elements") }
    
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
 
    static func setter() -> [Setter] {
        return [
            Element.id <- id,
            Element.name <- name,
            Element.value <- value
        ]
    }
 }
 
 ```
 */
public protocol Migrator {
    static var table: Tablex { get }
    /**
     Migrate sqlite datebase schema
     ```
     // Sample
     static func migrate(_ conn: Connection) throws {
        try conn.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(name, unique: true)
            t.column(value)
        })
        try conn.run(table.createIndex(name, ifNotExists: true))
     }
     ```
     
     */
    static func migrate(_:Connection) throws
    /**
     Parse object from result row
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
     Use for Insert/ Update/ Upsert function
     ```
     // Sample
     static func setter() -> [Setter] {
        return [
            Element.id <- id,
            Element.name <- name,
            Element.value<- value
        ]
     }
     ```
     */
    func setter() -> [Setter]
}

// MARK: Connection
extension Connection {
    /** Run table migrations */
    public func migrate(_ migrators: [Migrator.Type]) {
        do {
            for m in migrators {
                try m.migrate(self)
            }
        } catch {
            print("migrate tables, err: \(error)")
        }
    }
    /** Query Element Properties */
    public func query<V: Value>(_ model: Migrator.Type, _ query: ((Tablex) -> ScalarQuery<V>)) throws -> V {
        return try self.scalar(query(model.table))
    }
    
    /** Query Element */
    public func query(_ model: Migrator.Type, _ query: ((Tablex) -> QueryType)) throws -> AnySequence<Row> {
        return try self.prepare(query(model.table))
    }
    
    /** Print Schema of Inputed Table Name */
    public func PrintSchema(_ tableName: String) throws {
        let columns = try self.schema.columnDefinitions(table: tableName)
        print("'\(tableName)' schema:")
        for column in columns {
            print("'\(column.name)', type: \(column.type.rawValue), pk: \(column.primaryKey != nil ? "Yes" : "-"), nullable: \(column.nullable)")
        }
    }
    
    /** Insert Element Using Defined Setter */
    public func insert(_ m: Migrator) throws -> Int64 {
        return try self.run(T(m).table.insert(m.setter()))
    }
    
    /** Upsert Element Using Defined Setter */
    public func upsert(_ m: Migrator, primaryKey pk: Expressible, `where`: Expression<Bool>) throws -> Int64 {
        return try SQL.getDriver().run(T(m).table.where(`where`).upsert(m.setter(), onConflictOf: pk, set: m.setter()))
    }
    
    /** Update Element Using Defined Setter */
    public func update(_ m: Migrator, `where`: Expression<Bool>) throws -> Int {
        return try SQL.getDriver().run(T(m).table.where(`where`).update(m.setter()))
    }
    
    /** Delete Element */
    public func delete(_ model: Migrator.Type, _ query: ((Tablex) -> QueryType)) throws -> Int {
        return try self.run(query(model.table).delete())
    }
}

fileprivate extension Connection {
    private func T(_ m: Migrator) -> Migrator.Type {
        return type(of: m)
    }
}
