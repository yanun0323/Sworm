# Sworm

The fantastic ORM library of [SQLite](https://github.com/stephencelis/SQLite.swift) for Swift, makes life easier.

### Sample Code

#### Definition
```swift
// implement Migrator protocol
extension Element: Migrator {
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let value = Expression<Decimal>("value")
    
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
}

// setter is for quick insert/update/upsert
func setter() -> [Setter] {
    return [
        Element.id <- id,
        Element.name <- name,
        Element.age <- age
    ]
}
```

#### Usage
```swift
// init SQLite database and migrate tables with structures
// before you do every thing
func setup() {
    let db = SQL.setup(dbName: "database", isMock: false)
    db.migrate([Element.self])
}

// query
func getElement(_ id: Int64) throws -> Element? {
    let result = try SQL.getDriver().query(Element.self) { $0.where(Record.id == id) }
    for row in result {
        return try Element.parse(row)
    }
    return nil
}

func listElements() throws -> [Element] {
    let result = try SQL.getDriver().query(Element.self) { $0.where(Record.id == id) }
    var elems: [Element] = []
    for r in results {
        elems.append(try Element.parse(r))
    }
    return elems
}

// insert
func createElement(_ elem: Element) throws -> Int64 {
    return try SQL.getDriver().insert(elem)
}

// update
func updateElement(_ elem: Element) throws -> Int {
    return try SQL.getDriver().update(elem, where: Element.id == r.id)
}

// upsert
func upsertElement(_ elem: Element) throws -> Int64 {
    return try SQL.getDriver().upsert(elem, Element.id, where: Element.id == r.id)
}

// delete
func deleteElement(_ id: Int64) throws -> Int {
    return try SQL.getDriver().run(Element.table.filter(Element.id == id).delete())
}
```
