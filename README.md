# Sworm

The fantastic SQLite ORM library for Swift base on [SQLite](https://github.com/stephencelis/SQLite.swift).

### Sample Code

#### Definition
```swift
// implement Model protocol
extension Element: Model {
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let value = Expression<Decimal>("value")
    
    static var table: Tablex { .init("elements") }
    
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

    // setter is for quick insert/update/upsert
    // ** please DO NOT set primary key in setter **
    func setter() -> [Setter] {
        return [
            Element.name <- name,
            Element.age <- age
        ]
    }
}
```

#### Usage
```swift
// initialize SQLite database and migrate tables with structures
// before you do every thing
func setup() {
    let db = Sworm.setup(dbName: "database", isMock: false)
    db.migrate(Element.self, Record.self)
}

// query
func getElement(_ id: Int64) throws -> Element? {
    return try Sworm.db.query(Element.self) { $0.where(Element.id == id) }.first
}

func listElements() throws -> [Element] {
    return try Sworm.db.query(Element.self) { $0 }
}

// insert
func createElement(_ elem: Element) throws -> Int64 {
    return try Sworm.db.insert(elem)
}

// update
func updateElement(_ elem: Element) throws -> Int {
    return try Sworm.db.update(elem) { $0.where(Element.id == elem.id) }
}

// upsert
func upsertElement(_ elem: Element) throws -> Int64 {
    return try Sworm.db.upsert(elem, Element.id) { $0.where(Element.id == elem.id) }
}

// delete
func deleteElement(_ id: Int64) throws -> Int {
    return try Sworm.db.delete(Element.self) { $0.where(Element.id == id)
}
```
