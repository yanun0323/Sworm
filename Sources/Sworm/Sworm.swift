import SQLite
import SwiftUI

public typealias Tablex = SQLite.Table
public typealias DB = SQLite.Connection

// MARK: SQLite Instance
/**
 property wrapper for SQLite instance
 
 ```
 // initial the SQL before use it
 let db = Sworm.setup(dbName: "database", isMock: false) /* use in memory sqlite database if isMock is true*/
 // get db
 let db = Sworm.getDriver()
 ```
 */
public struct Sworm {
    private static var _db: DB? = nil
}

extension Sworm {
    /** get sqlite database instance. if no exist, create a in memory sqlite database  connection */
    public static var db: DB {
        if let conn = _db {
            return conn
        }
        return self.setup(isMock: true)
    }
    
    /** create a new sqlite database instance, use in memory sqlite database if isMock is true */
    public static func setup(dbName name: String? = nil, isMock: Bool) -> DB {
        var dbName = "production"
        if let name = name, !name.isEmpty {
            dbName = name
        }
        let conn: DB
        if isMock && (name == nil || name!.isEmpty) {
            conn = try! DB(.inMemory)
        } else {
            conn = try! DB(filePath(dbName))
        }
        conn.busyTimeout = 5
        
        _db = conn
        return _db!
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
     migrate sqlite datebase schema
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

// MARK: Connection
extension DB {
    /** run table migrations */
    public func migrate(_ migrators: Migrator.Type...) {
        do {
            for m in migrators {
                try m.migrate(self)
            }
        } catch {
            print("migrate tables, err: \(error)")
        }
    }
    
    /// runs a transaction with the given mode.
    ///
    /// - Note: Transactions cannot be nested. To nest transactions, see
    ///   `savepoint()`, instead.
    ///
    /// - Parameters:
    ///
    ///   - mode: The mode in which a transaction acquires a lock.
    ///
    ///     Default: `.deferred`
    ///
    ///   - block: A closure to run SQL statements within the transaction.
    ///     The transaction will be committed when the block returns. The block
    ///     must throw to roll the transaction back.
    ///
    /// - Throws: `Result.Error`, and rethrows.
    public func tx(_ mode: TransactionMode = .deferred, action: () throws -> Void) throws {
        try self.transaction(mode, block: action)
    }
    
    /** query element properties */
    public func query<V: Value>(_ model: Migrator.Type, _ query: @escaping ((Tablex) -> ScalarQuery<V>)) throws -> V {
        return try self.scalar(query(model.table))
    }
    
    /** query element */
    public func query(_ model: Migrator.Type, _ query: @escaping ((Tablex) -> QueryType)) throws -> AnySequence<Row> {
        return try self.prepare(query(model.table))
    }
    
    /** print schema of inputed table name */
    public func printSchema(_ tableName: String) throws {
        let columns = try self.schema.columnDefinitions(table: tableName)
        print("'\(tableName)' schema:")
        for column in columns {
            print("'\(column.name)', type: \(column.type.rawValue), pk: \(column.primaryKey != nil ? "Yes" : "-"), nullable: \(column.nullable)")
        }
    }
    
    /** insert element using defined setter */
    public func insert(_ m: Migrator) throws -> Int64 {
        return try self.run(T(m).table.insert(m.setter()))
    }
    
    /** upsert element using defined setter */
    public func upsert(_ m: Migrator, primaryKey pk: Expressible, `where` filter: Expression<Bool>) throws -> Int64 {
        return try self.run(T(m).table.where(filter).upsert(m.setter(), onConflictOf: pk, set: m.setter()))
    }
    
    /** update element using defined setter */
    public func update(_ m: Migrator, `where` filter: Expression<Bool>) throws -> Int {
        return try self.run(T(m).table.where(filter).update(m.setter()))
    }
    
    /** delete element */
    public func delete(_ model: Migrator.Type, _ query: @escaping ((Tablex) -> QueryType)) throws -> Int {
        return try self.run(query(model.table).delete())
    }
}

fileprivate extension DB {
    func T(_ m: Migrator) -> Migrator.Type {
        return type(of: m)
    }
}
