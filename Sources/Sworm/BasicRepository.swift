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
    func tx(action: @escaping () throws -> Void, success: @escaping () -> Void, fail: @escaping (Error) -> Void)
    
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
    func tx(action: @escaping () throws -> Void, fail: @escaping (Error) -> Void)
    
    
    
    // MARK: - Query
    /** query element properties */
    func query<V: Value>(_ model: Model.Type, query filter: @escaping (Tablex) -> ScalarQuery<V>) -> (V?, Error?)
    
    /** query element */
    func query<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) -> ([M], Error?)
    
    // MARK: - Insert
    /** insert element. using defined setter when providing nil setter */
    func insert(_ m: Model) -> (Int64, Error?)
    
    /** insert element. using defined setter when providing nil setter */
    func insert(_ m: Model, _ insertValues: [Setter]) -> (Int64, Error?)
    
    // MARK: - Upsert
    /** upsert element. using defined setter when providing nil setter */
    func upsert(_ m: Model, onConflictOf primaryKey: Expressible) -> (Int64, Error?)
    
    /** upsert element. using defined setter when providing nil setter */
    func upsert(_ m: Model, _ insertValues: [Setter], onConflictOf primaryKey: Expressible) -> (Int64, Error?)
    
    /** upsert element. using defined setter when providing nil setter */
    func upsert(_ m: Model, onConflictOf primaryKey: Expressible, set setValues: [Setter]) -> (Int64, Error?)
    
    /** upsert element. using defined setter when providing nil setter */
    func upsert(_ m: Model, _ insertValues: [Setter], onConflictOf primaryKey: Expressible, set setValues: [Setter]) -> (Int64, Error?)
    
    // MARK: - Update
    /** update element. using defined setter when providing nil setter */
    func update(_ m: Model, query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?)
    
    /** update element. using defined setter when providing nil setter */
    func update(_ m: Model, set setValues: [Setter], query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?)
    
    // MARK: - Delete
    /** delete element */
    func delete(_ model: Model.Type, query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?)
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
    
    public func tx(action: @escaping () throws -> Void, success: @escaping () -> Void, fail: @escaping (Error) -> Void) {
        do {
            try Sworm.db.tx {
                try action()
            }
            success()
        } catch {
            fail(error)
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
    
    public func tx(action: @escaping () throws -> Void, fail: @escaping (Error) -> Void) {
        do {
            try Sworm.db.tx {
                try action()
            }
        } catch {
            fail(error)
        }
    }
    
    public func query<V: Value>(_ model: Model.Type, query filter: @escaping (Tablex) -> ScalarQuery<V>) -> (V?, Error?) {
        do {
            return (try Sworm.db.query(model, query: filter), nil)
        } catch {
            return (nil, error)
        }
    }
    
    public func query<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) -> ([M], Error?) {
        do {
            return (try Sworm.db.query(model, query: filter), nil)
        } catch {
            return ([], error)
        }
    }
    
    public func insert(_ m: Model) -> (Int64, Error?) {
        do {
            return (try Sworm.db.insert(m), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func insert(_ m: Model, _ insertValues: [Setter]) -> (Int64, Error?) {
        do {
            return (try Sworm.db.insert(m, insertValues), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func upsert(_ m: Model, onConflictOf primaryKey: Expressible) -> (Int64, Error?) {
        do {
            return (try Sworm.db.upsert(m, onConflictOf: primaryKey), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func upsert(_ m: Model, _ insertValues: [Setter], onConflictOf primaryKey: Expressible) -> (Int64, Error?) {
        do {
            return (try Sworm.db.upsert(m, insertValues, onConflictOf: primaryKey), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func upsert(_ m: Model, onConflictOf primaryKey: Expressible, set setValues: [Setter]) -> (Int64, Error?) {
        do {
            return (try Sworm.db.upsert(m, onConflictOf: primaryKey, set: setValues), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func upsert(_ m: Model, _ insertValues: [Setter], onConflictOf primaryKey: Expressible, set setValues: [Setter]) -> (Int64, Error?) {
        do {
            return (try Sworm.db.upsert(m, insertValues, onConflictOf: primaryKey, set: setValues), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func update(_ m: Model, query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?) {
        do {
            return (try Sworm.db.update(m, query: filter), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func update(_ m: Model, set setValues: [Setter], query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?) {
        do {
            return (try Sworm.db.update(m, set: setValues, query: filter), nil)
        } catch {
            return (0, error)
        }
    }
    
    public func delete(_ model: Model.Type, query filter: @escaping (Tablex) -> QueryType) -> (Int, Error?) {
        do {
            return (try Sworm.db.delete(model, query: filter), nil)
        } catch {
            return (0, error)
        }
    }
    
}
