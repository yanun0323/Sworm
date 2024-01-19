import SQLite
import SwiftUI

public protocol BasicRepository {
    /// runs a transaction with the given mode.
    ///
    /// - Note: Transactions cannot be nested. To nest transactions, see
    ///   `savepoint()`, instead.
    ///
    /// - Parameters:
    ///
    ///   - block: A closure to run SQL statements within the transaction.
    ///     The transaction will be committed when the block returns. The block
    ///     must throw to roll the transaction back.
    ///
    /// - Throws: `Result.Error`, and rethrows.
    func tx(action: () throws -> Void) throws
    
    /** query element properties */
    func query<V: Value>(_ model: Migrator.Type, _ query: @escaping ((Tablex) -> ScalarQuery<V>)) throws -> V
    
    /** query element */
    func query(_ model: Migrator.Type, _ query: @escaping ((Tablex) -> QueryType)) throws -> AnySequence<Row>
    
    /** insert element using defined setter */
    func insert(_ m: Migrator) throws -> Int64
    
    /** upsert element using defined setter */
    func upsert(_ m: Migrator, primaryKey pk: Expressible, `where` filter: Expression<Bool>) throws -> Int64
    
    /** update element using defined setter */
    func update(_ m: Migrator, `where` filter: Expression<Bool>) throws -> Int
    
    /** delete element */
    func delete(_ model: Migrator.Type, _ query: @escaping ((Tablex) -> QueryType)) throws -> Int
}

public protocol BasicDao {}

extension BasicDao where Self: BasicRepository {
    /// runs a transaction with the given mode.
    ///
    /// - Note: Transactions cannot be nested. To nest transactions, see
    ///   `savepoint()`, instead.
    ///
    /// - Parameters:
    ///
    ///   - block: A closure to run SQL statements within the transaction.
    ///     The transaction will be committed when the block returns. The block
    ///     must throw to roll the transaction back.
    ///
    /// - Throws: `Result.Error`, and rethrows.
    public func tx(action: () throws -> Void) throws {
        return try Sworm.db.tx(action: action)
    }
    
    /** query element properties */
    public func query<V: Value>(_ model: Migrator.Type, _ query: @escaping ((Tablex) -> ScalarQuery<V>)) throws -> V {
        return try Sworm.db.query(model, query)
    }
    
    /** query element */
    public func query(_ model: Migrator.Type, _ query: @escaping ((Tablex) -> QueryType)) throws -> AnySequence<Row> {
        return try Sworm.db.query(model, query)
    }
    
    /** insert element using defined setter */
    public func insert(_ m: Migrator) throws -> Int64 {
        return try Sworm.db.insert(m)
    }
    
    /** upsert element using defined setter */
    public func upsert(_ m: Migrator, primaryKey pk: Expressible, `where` filter: Expression<Bool>) throws -> Int64 {
        return try Sworm.db.upsert(m, primaryKey: pk, where: filter)
    }
    
    /** update element using defined setter */
    public func update(_ m: Migrator, `where` filter: Expression<Bool>) throws -> Int {
        return try Sworm.db.update(m, where: filter)
    }
    
    /** delete element */
    public func delete(_ model: Migrator.Type, _ query: @escaping ((Tablex) -> QueryType)) throws -> Int {
        return try Sworm.db.delete(model, query)
    }
}
