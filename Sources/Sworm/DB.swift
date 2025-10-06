import Foundation
import SQLite

// MARK: DB
extension DB {
    /** run table migrations */
    public func migrate<M: Model>(_ Models: M.Type...) {
        do {
            for m in Models {
                try m.migrate(self)
            }
        } catch {
            print("migrate tables, err: \(error)")
        }
    }

    /** run table dropping */
    public func drop<M: Model>(_ Models: M.Type...) {
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
            print(
                "'\(column.name)', type: \(column.type.rawValue), pk: \(column.primaryKey != nil ? "Yes" : "-"), nullable: \(column.nullable)"
            )
        }
    }

    // MARK: - Query
    /** query element properties */
    public func query<V: Value, M: Model>(
        _ model: M.Type,
        query filter: @escaping (Tablex) -> ScalarQuery<V>
    ) throws -> V {
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
    public func insert<M: Model>(_ m: M, _ insertValues: Setter...) throws -> Int64 {
        return try self.insert(m, insertValues)
    }

    /** insert element. using defined setter when providing empty setter */
    public func insert<M: Model>(_ m: M, _ insertValues: [Setter] = []) throws -> Int64 {
        return try self.run(T(m).table.insert(m.get(insertValues, primaryKey: true)))
    }

    // MARK: - Upsert
    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    public func upsert<M: Model>(_ m: M, _ insertValues: Setter..., set setValues: Setter...) throws -> Int64 {
        return try self.upsert(m, insertValues, set: setValues)
    }

    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    public func upsert<M: Model>(_ m: M, _ insertValues: [Setter], set setValues: Setter...) throws -> Int64 {
        return try self.upsert(m, insertValues, set: setValues)
    }

    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    public func upsert<M: Model>(_ m: M, _ insertValues: Setter..., set setValues: [Setter]) throws -> Int64 {
        return try self.upsert(m, insertValues, set: setValues)
    }

    /// upsert element. using defined setter when providing empty setter
    /// - NOTE: It would using defined setter which auto appended primary key when not providing insert values
    public func upsert<M: Model>(_ m: M, _ insertValues: [Setter] = [], set setValues: [Setter] = []) throws -> Int64 {
        return try self.run(
            T(m).table.upsert(m.get(insertValues, primaryKey: true), onConflictOf: T(m).id, set: m.get(setValues))
        )
    }

    // MARK: - Update
    /** update element. using defined setter when providing empty setter */
    public func update<M: Model>(
        _ m: M,
        set setValues: Setter...,
        query filter: @escaping (Tablex) -> QueryType
    ) throws -> Int {
        return try self.update(m, set: setValues, query: filter)
    }

    /** update element. using defined setter when providing empty setter */
    public func update<M: Model>(
        _ m: M,
        set setValues: [Setter] = [],
        query filter: @escaping (Tablex) -> QueryType
    ) throws -> Int {
        return try self.run(filter(T(m).table).update(m.get(setValues)))
    }

    // MARK: - Delete
    /** delete element */
    public func delete<M: Model>(_ model: M.Type, query filter: @escaping (Tablex) -> QueryType) throws -> Int {
        return try self.run(filter(model.table).delete())
    }
}

fileprivate extension DB {
    func T<M: Model>(_ m: M) -> M.Type {
        return type(of: m)
    }
}

extension Setter: @retroactive Equatable {
    public static func == (lhs: Setter, rhs: Setter) -> Bool {
        return lhs.expression.template.description == rhs.expression.template.description
    }
}

public struct Result {}

extension DB {
    /** execute raw sql with return type */
    public func execute<T: Decodable>(_ sql: String, _ args: Any...) throws -> [T] {
        var query = sql
        var argIndex = 0

        // Find and replace each "?" with the corresponding argument
        while let range = query.range(of: "?"), argIndex < args.count {
            let arg = args[argIndex]
            let replacement = formatArgument(arg)
            query.replaceSubrange(range, with: replacement)
            argIndex += 1
        }

        let statement = try self.run(query)

        // 1. Row → Dictionary
        var results: [[String: Any]] = []
        for row in statement {
            var dict: [String: Any] = [:]
            for (index, name) in statement.columnNames.enumerated() {
                if let value = row[index] {
                    dict[name] = convertValue(value)
                }
            }
            results.append(dict)
        }

        let jsonData = try JSONSerialization.data(withJSONObject: results)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode([T].self, from: jsonData)
    }

    public func execute(_ sql: String, _ args: Any...) throws {
        var query = sql
        var argIndex = 0

        // Find and replace each "?" with the corresponding argument
        while let range = query.range(of: "?"), argIndex < args.count {
            let arg = args[argIndex]
            let replacement = formatArgument(arg)
            query.replaceSubrange(range, with: replacement)
            argIndex += 1
        }

        let _ = try self.run(query)
    }

    // Format argument for SQL
    private func formatArgument(_ arg: Any) -> String {
        // Handle array types (for IN clause)
        if let array = arg as? [Any] {
            let items = array.map { formatSingleValue($0) }
            return items.joined(separator: ", ")
        }

        return formatSingleValue(arg)
    }

    private func convertValue(_ value: Binding) -> Any {
        switch value {
        case let int64 as Int64:
            return Int(int64)
        case let double as Double:
            return double
        case let string as String:
            return string
        case let blob as Blob:
            return Data(blob.bytes).base64EncodedString()
        case let bool as Bool:
            return bool
        default:
            return value
        }
    }

    // Format single value
    private func formatSingleValue(_ value: Any) -> String {
        switch value {
        case let str as String:
            // Escape single quotes and wrap in quotes
            let escaped = str.replacingOccurrences(of: "'", with: "''")
            return "'\(escaped)'"
        case let date as Date:
            // Store Date as Unix timestamp (seconds since 1970)
            return "\(Int64(date.timeIntervalSince1970))"
        case let num as Int:
            return "\(num)"
        case let num as Int32:
            return "\(num)"
        case let num as Int64:
            return "\(num)"
        case let num as Double:
            return "\(num)"
        case let num as Float:
            return "\(num)"
        case let bool as Bool:
            return bool ? "true" : "false"
        default:
            // For other types, convert to string and treat as string
            return "'\(value)'"
        }
    }
}
