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
    func tx(action: @escaping () throws -> Void) -> Error?
    
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
    func tx(action: @escaping () throws -> Void, success: @escaping () -> Void, failed: @escaping (Error) -> Void)
    
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
    func tx(action: @escaping () throws -> Void, success: @escaping () -> Void) -> Error?
    
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
    func tx(action: @escaping () throws -> Void, failed: @escaping (Error) -> Void)
    
    // MARK: - Query
    /** query element properties */
    func query<V: Value, M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> ScalarQuery<V>) -> (V?, Error?)
    
    /** query element properties */
    func query<V: Value, M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> ScalarQuery<V>) throws -> V
    
    /** query element */
    func query<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) -> ([M], Error?)
    
    /** query element */
    func query<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) throws -> [M]
    
    // MARK: - Insert
    /** insert element. using defined setter when providing nil setter */
    
    func insert<M: Model>(_ m: M) -> (Int64, Error?)
    /** insert element. using defined setter when providing nil setter */
    func insert<M: Model>(_ m: M) throws -> Int64
    
    /** insert element. using defined setter when providing nil setter */
    func insert<M: Model>(_ m: M, _ insertValues: [Setter]) -> (Int64, Error?)
    
    /** insert element. using defined setter when providing nil setter */
    func insert<M: Model>(_ m: M, _ insertValues: [Setter]) throws -> Int64
    
    // MARK: - Upsert
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    func upsert<M: Model>(_ m: M) -> (Int64, Error?)
    
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    func upsert<M: Model>(_ m: M) throws -> Int64
    
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    func upsert<M: Model>(_ m: M, _ insertValues: [Setter]) -> (Int64, Error?)
    
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    func upsert<M: Model>(_ m: M, _ insertValues: [Setter]) throws -> Int64
    
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    func upsert<M: Model>(_ m: M, set setValues: [Setter]) -> (Int64, Error?)
    
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    func upsert<M: Model>(_ m: M, set setValues: [Setter]) throws -> Int64
    
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    func upsert<M: Model>(_ m: M, _ insertValues: [Setter], set setValues: [Setter]) -> (Int64, Error?)
    
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    func upsert<M: Model>(_ m: M, _ insertValues: [Setter], set setValues: [Setter]) throws -> Int64
    
    // MARK: - Update
    /** update element. using defined setter when providing empty setter */
    func update<M: Model>(_ m: M, query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?)
    
    /** update element. using defined setter when providing empty setter */
    func update<M: Model>(_ m: M, query filter: @escaping (Tablex) -> QueryType) throws -> Int
    
    /** update element. using defined setter when providing empty setter */
    func update<M: Model>(_ m: M, set setValues: [Setter], query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?)
    
    /** update element. using defined setter when providing empty setter */
    func update<M: Model>(_ m: M, set setValues: [Setter], query filter: @escaping (Tablex) -> QueryType) throws -> Int
    
    // MARK: - Delete
    /** delete element */
    func delete<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?)
    
    /** delete element */
    func delete<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) throws -> Int
}

public protocol BasicDao {}

extension BasicDao where Self: BasicRepository {
    public func tx(action: @escaping () throws -> Void) -> Error? {
        do {
            try Sworm.db.tx {
                try action()
            }
            return nil
        } catch {
            return error
        }
    }
    
    public func tx(action: @escaping () throws -> Void, success: @escaping () -> Void, failed: @escaping (Error) -> Void) {
        do {
            try Sworm.db.tx {
                try action()
            }
            success()
        } catch {
            failed(error)
        }
    }
    
    public func tx(action: @escaping () throws -> Void, success: @escaping () -> Void) -> Error? {
        do {
            try Sworm.db.tx {
                try action()
            }
            success()
            return nil
        } catch {
            return error
        }
    }
    
    public func tx(action: @escaping () throws -> Void, failed: @escaping (Error) -> Void) {
        do {
            try Sworm.db.tx {
                try action()
            }
        } catch {
            failed(error)
        }
    }
    
    public func query<V: Value, M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> ScalarQuery<V>) -> (V?, Error?) {
        do {
            return (try Sworm.db.query(model, query: filter), nil)
        } catch {
            return (nil, error)
        }
    }
    
    public func query<V: Value, M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> ScalarQuery<V>) throws -> V {
        return try Sworm.db.query(model, query: filter)
    }
    
    public func query<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) -> ([M], Error?) {
        do {
            return (try Sworm.db.query(model, query: filter), nil)
        } catch {
            return ([], error)
        }
    }
    
    public func query<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) throws -> [M] {
        return try Sworm.db.query(model, query: filter)
    }
    
    public func insert<M: Model>(_ m: M) -> (Int64, Error?) {
        do {
            return (try Sworm.db.insert(m), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func insert<M: Model>(_ m: M) throws -> Int64 {
        return try Sworm.db.insert(m)
    }
    
    public func insert<M: Model>(_ m: M, _ insertValues: [Setter]) -> (Int64, Error?) {
        do {
            return (try Sworm.db.insert(m, insertValues), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func insert<M: Model>(_ m: M, _ insertValues: [Setter]) throws -> Int64 {
        return try Sworm.db.insert(m, insertValues)
    }
    
    public func upsert<M: Model>(_ m: M) -> (Int64, Error?) {
        do {
            return (try Sworm.db.upsert(m), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func upsert<M: Model>(_ m: M) throws -> Int64 {
        return try Sworm.db.upsert(m)
    }
    
    public func upsert<M: Model>(_ m: M, _ insertValues: [Setter]) -> (Int64, Error?) {
        do {
            return (try Sworm.db.upsert(m, insertValues), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func upsert<M: Model>(_ m: M, _ insertValues: [Setter]) throws -> Int64 {
        return try Sworm.db.upsert(m, insertValues)
    }
    
    public func upsert<M: Model>(_ m: M, set setValues: [Setter]) -> (Int64, Error?) {
        do {
            return (try Sworm.db.upsert(m, set: setValues), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func upsert<M: Model>(_ m: M, set setValues: [Setter]) throws -> Int64 {
        return try Sworm.db.upsert(m, set: setValues)
    }
    
    public func upsert<M: Model>(_ m: M, _ insertValues: [Setter], set setValues: [Setter]) -> (Int64, Error?) {
        do {
            return (try Sworm.db.upsert(m, insertValues, set: setValues), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func upsert<M: Model>(_ m: M, _ insertValues: [Setter], set setValues: [Setter]) throws -> Int64 {
        return try Sworm.db.upsert(m, insertValues, set: setValues)
    }
    
    public func update<M: Model>(_ m: M, query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?) {
        do {
            return (try Sworm.db.update(m, query: filter), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func update<M: Model>(_ m: M, query filter: @escaping (Tablex) -> QueryType) throws -> Int {
        return try Sworm.db.update(m, query: filter)
    }
    
    public func update<M: Model>(_ m: M, set setValues: [Setter], query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?) {
        do {
            return (try Sworm.db.update(m, set: setValues, query: filter), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func update<M: Model>(_ m: M, set setValues: [Setter], query filter: @escaping (Tablex) -> QueryType) throws -> Int {
        return try Sworm.db.update(m, set: setValues, query: filter)
    }
    
    public func delete<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?) {
        do {
            return (try Sworm.db.delete(model, query: filter), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func delete<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) throws -> Int {
        return try Sworm.db.delete(model, query: filter)
    }
    
}
