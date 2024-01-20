import SQLite

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
    
    
    
    // MARK: - Query
    /** query element properties */
    func query<V: Value>(_ model: Model.Type, query filter: @escaping (Tablex) -> ScalarQuery<V>) throws -> V
    
    /** query element */
    func query<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) throws -> [M]
    
    // MARK: - Insert
    /** insert element. using defined setter when providing nil setter */
    func insert(_ m: Model, _ insertValues: Setter...) throws -> Int64
    
    /** insert element. using defined setter when providing nil setter */
    func insert(_ m: Model, _ insertValues: [Setter]) throws -> Int64
    
    // MARK: - Upsert
    /** upsert element. using defined setter when providing nil setter */
    func upsert(_ m: Model, _ insertValues: Setter..., onConflictOf primaryKey: Expressible, set setValues: Setter...) throws -> Int64
    
    /** upsert element. using defined setter when providing nil setter */
    func upsert(_ m: Model, _ insertValues: [Setter], onConflictOf primaryKey: Expressible, set setValues: Setter...) throws -> Int64
    
    /** upsert element. using defined setter when providing nil setter */
    func upsert(_ m: Model, _ insertValues: Setter..., onConflictOf primaryKey: Expressible, set setValues: [Setter]) throws -> Int64
    
    /** upsert element. using defined setter when providing nil setter */
    func upsert(_ m: Model, _ insertValues: [Setter], onConflictOf primaryKey: Expressible, set setValues: [Setter]) throws -> Int64
    
    // MARK: - Update
    /** update element. using defined setter when providing nil setter */
    func update(_ m: Model, set setValues: Setter..., query filter: @escaping (Tablex) -> QueryType) throws -> Int
    
    /** update element. using defined setter when providing nil setter */
    func update(_ m: Model, set setValues: [Setter], query filter: @escaping (Tablex) -> QueryType) throws -> Int
    
    // MARK: - Delete
    /** delete element */
    func delete(_ model: Model.Type, query filter: @escaping (Tablex) -> QueryType) throws -> Int
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
    
    // MARK: - Query
    /** query element properties */
    public func query<V: Value>(_ model: Model.Type, query filter: @escaping (Tablex) -> ScalarQuery<V>) throws -> V {
        return try Sworm.db.query(model, query: filter)
    }
    
    /** query element */
    public func query<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) throws -> [M] {
        return try Sworm.db.query(model, query: filter)
    }
    
    
    // MARK: - Insert
    /** insert element. using defined setter when providing nil setter */
    public func insert(_ m: Model, _ insertValues: Setter...) throws -> Int64 {
        return try Sworm.db.insert(m, insertValues)
    }
    
    /** insert element. using defined setter when providing nil setter */
    public func insert(_ m: Model, _ insertValues: [Setter]) throws -> Int64 {
        return try Sworm.db.insert(m, insertValues)
    }
    
    // MARK: - Upsert
    /** upsert element. using defined setter when providing nil setter */
    public func upsert(_ m: Model, _ insertValues: Setter..., onConflictOf primaryKey: Expressible, set setValues: Setter...) throws -> Int64 {
        return try Sworm.db.upsert(m, insertValues, onConflictOf: primaryKey, set: insertValues)
    }
    
    /** upsert element. using defined setter when providing nil setter */
    public func upsert(_ m: Model, _ insertValues: [Setter], onConflictOf primaryKey: Expressible, set setValues: Setter...) throws -> Int64 {
        return try Sworm.db.upsert(m, insertValues, onConflictOf: primaryKey, set: insertValues)
    }
    
    /** upsert element. using defined setter when providing nil setter */
    public func upsert(_ m: Model, _ insertValues: Setter..., onConflictOf primaryKey: Expressible, set setValues: [Setter]) throws -> Int64 {
        return try Sworm.db.upsert(m, insertValues, onConflictOf: primaryKey, set: insertValues)
    }
    
    /** upsert element. using defined setter when providing nil setter */
    public func upsert(_ m: Model, _ insertValues: [Setter], onConflictOf primaryKey: Expressible, set setValues: [Setter]) throws -> Int64 {
        return try Sworm.db.upsert(m, insertValues, onConflictOf: primaryKey, set: insertValues)
    }
    
    // MARK: - Update
    /** update element. using defined setter when providing nil setter */
    public func update(_ m: Model, set setValues: Setter..., query filter: @escaping (Tablex) -> QueryType) throws -> Int {
        return try Sworm.db.update(m, set: setValues, query: filter)
    }
    
    /** update element. using defined setter when providing nil setter */
    public func update(_ m: Model, set setValues: [Setter], query filter: @escaping (Tablex) -> QueryType) throws -> Int {
        return try Sworm.db.update(m, set: setValues, query: filter)
    }
    
    // MARK: - Delete
    /** delete element */
    public func delete(_ model: Model.Type, query filter: @escaping (Tablex) -> QueryType) throws -> Int {
        return try Sworm.db.delete(model, filter)
    }
}
