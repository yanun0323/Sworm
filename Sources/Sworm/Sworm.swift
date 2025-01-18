import SQLite
import SwiftUI

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
        return self.setup(mock: true)
    }
    
    /** create a new sqlite database instance, use in memory sqlite database if isMock is true */
    public static func setup(_ name: String? = nil, mock inMemory: Bool) -> DB {
        var database = "production"
        if let name = name, !name.isEmpty {
            database = name
        }
        let conn: DB
        if inMemory && (name == nil || name!.isEmpty) {
            conn = try! DB(.inMemory)
        } else {
            conn = try! DB(filePath(database))
        }
        conn.busyTimeout = 5
        
        _db = conn
        return conn
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
        
        Sworm.debug(path)
        
        return "\(path)/\(filename).sqlite3"
    }
}
