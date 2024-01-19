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
   
   /** print schema of inputed table name */
   public func printSchema(_ tableName: String) throws {
       let columns = try self.schema.columnDefinitions(table: tableName)
       print("'\(tableName)' schema:")
       for column in columns {
           print("'\(column.name)', type: \(column.type.rawValue), pk: \(column.primaryKey != nil ? "Yes" : "-"), nullable: \(column.nullable)")
       }
   }
   
   /** query element properties */
   public func query<V: Value>(_ model: Model.Type, _ query: @escaping (Tablex) -> ScalarQuery<V>) throws -> V {
       return try self.scalar(query(model.table))
   }
   
   /** query element */
   public func query<M: Model>(_ model: M.Type, _ query: @escaping (Tablex) -> QueryType) throws -> [M] {
       let rows = try self.prepare(query(model.table))
       var result = [M]()
       for row in rows {
           result.append(try model.parse(row))
       }
       return result
   }
   
   /** insert element. using defined setter when providing nil setter */
   public func insert(_ m: Model, set: [Setter]? = nil) throws -> Int64 {
       return try self.run(T(m).table.insert(set ?? m.setter()))
   }
   
   /** upsert element. using defined setter when providing nil setter */
   public func upsert(_ m: Model, primaryKey pk: Expressible, set: [Setter]? = nil, _ query: @escaping (Tablex) -> QueryType) throws -> Int64 {
       return try self.run(query(T(m).table).upsert(set ?? m.setter(), onConflictOf: pk, set: m.setter()))
   }
   
   /** update element. using defined setter when providing nil setter */
   public func update(_ m: Model, set: [Setter]? = nil, _ query:  @escaping (Tablex) -> QueryType) throws -> Int {
       return try self.run(query(T(m).table).update(set ?? m.setter()))
   }
   
   /** delete element */
   public func delete(_ model: Model.Type, _ query: @escaping (Tablex) -> QueryType) throws -> Int {
       return try self.run(query(model.table).delete())
   }
}

fileprivate extension DB {
   func T(_ m: Model) -> Model.Type {
       return type(of: m)
   }
}
