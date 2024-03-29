import SQLite

// MARK: DB
extension DB {
    /** run table migrations */
    public func migrate(_ Models: Model.Type...) {
        do {
            for m in Models {
                try m.migrate(self)
            }
        } catch {
            print("migrate tables, err: \(error)")
        }
    }
    
    /** run table dropping */
    public func drop(_ Models: Model.Type...) {
        do {
            for m in Models {
                try Sworm.db.run(m.table.drop(ifExists: true))
            }
        } catch {
            print("drop tables, err: \(error)")
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
    public func tx(_ mode: TransactionMode = .deferred, action: @escaping () throws -> Void) throws {
        try self.transaction(mode, block: action)
    }
    
    /** print schema of inputed table name */
    public func printSchema(_ tableName: String) throws {
        let columns = try self.schema.columnDefinitions(table: tableName)
        print("'\(tableName)' schema:")
        for column in columns {
            print("'\(column.name)', type: \(column.type.rawValue), pk: \(column.primaryKey != nil ? "Yes" : "-"), nullable: \(column.nullable)")
        }
    }
    
    // MARK: - Query
    /** query element properties */
    public func query<V: Value>(_ model: Model.Type, query filter: @escaping (Tablex) -> ScalarQuery<V>) throws -> V {
        return try self.scalar(filter(model.table))
    }
    
    /** query element */
    public func query<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) throws -> [M] {
        let rows = try self.prepare(filter(model.table))
        var result = [M]()
        for row in rows {
            result.append(try model.parse(row))
        }
        return result
    }
    
    // MARK: - Insert
    /** insert element. using defined setter when providing empty setter */
    public func insert(_ m: Model, _ insertValues: Setter...) throws -> Int64 {
        return try self.insert(m, insertValues)
    }
    
    /** insert element. using defined setter when providing empty setter */
    public func insert(_ m: Model, _ insertValues: [Setter] = []) throws -> Int64 {
        return try self.run(T(m).table.insert(m.get(insertValues)))
    }
    
    // MARK: - Upsert
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values 
    public func upsert<Element: Value>(_ m: Model, _ insertValues: Setter..., onConflictOf primaryKey: Expression<Element>, primaryKey value: Element, set setValues: Setter...) throws -> Int64 {
         return try self.upsert(m, insertValues, onConflictOf: primaryKey, primaryKey: value, set: setValues)
    }
    
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    public func upsert<Element: Value>(_ m: Model, _ insertValues: [Setter], onConflictOf primaryKey: Expression<Element>, primaryKey value: Element, set setValues: Setter...) throws -> Int64 {
         return try self.upsert(m, insertValues, onConflictOf: primaryKey, primaryKey: value, set: setValues)
    }
    
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    public func upsert<Element: Value>(_ m: Model, _ insertValues: Setter..., onConflictOf primaryKey: Expression<Element>, primaryKey value: Element, set setValues: [Setter]) throws -> Int64 {
         return try self.upsert(m, insertValues, onConflictOf: primaryKey, primaryKey: value, set: setValues)
    }
    
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    public func upsert<Element: Value>(_ m: Model, _ insertValues: [Setter] = [], onConflictOf primaryKey: Expression<Element>, primaryKey value: Element, set setValues: [Setter] = []) throws -> Int64 {
        return try self.run(T(m).table.upsert(m.get(insertValues, primaryKey: (primaryKey <- value)), onConflictOf: primaryKey, set: m.get(setValues)))
    }
    
    // MARK: - Update
    /** update element. using defined setter when providing empty setter */
    public func update(_ m: Model, set setValues: Setter..., query filter: @escaping (Tablex) -> QueryType) throws -> Int {
         return try self.update(m, set: setValues, query: filter)
    }
    
    /** update element. using defined setter when providing empty setter */
    public func update(_ m: Model, set setValues: [Setter] = [], query filter: @escaping (Tablex) -> QueryType) throws -> Int {
        return try self.run(filter(T(m).table).update(m.get(setValues)))
    }
    
    // MARK: - Delete
    /** delete element */
    public func delete(_ model: Model.Type, query filter: @escaping (Tablex) -> QueryType) throws -> Int {
        return try self.run(filter(model.table).delete())
    }
}

fileprivate extension DB {
    func T(_ m: Model) -> Model.Type {
        return type(of: m)
    }
}



