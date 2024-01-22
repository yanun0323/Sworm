import SwiftUI

extension Sworm {
    #if DEBUG
    private static var level = LogLevel.debug
    #else
    private static var level = LogLevel.release
    #endif
    
    public enum LogLevel: UInt {
        case debug = 0
        case warning = 1
        case release = 2
        
        var string: String {
            switch self {
                case .debug:
                    return "DEBUG"
                case .warning:
                    return "WARNING"
                case .release:
                    return "RELEASE"
            }
        }
    }
    
    /**
     Set sqlite log level. If mode is debug, print detail log in console.
    - Default Value:
     ```
     #if DEBUG
     private static var level = LogLevel.debug
     #else
     private static var level = LogLevel.release
     #endif
     ```
     */
    public static func setLogLevel(_ level: Sworm.LogLevel) {
        Sworm.level = level
    }
    
    /**
     Get sqlite log level.
     */
    public static func logLevel() -> Sworm.LogLevel {
        return Sworm.level
    }
    
    private static func log(level: Sworm.LogLevel = .release, _ message: String) {
        if level.rawValue >= Sworm.level.rawValue {
            print("[\(level.string)] \(message)")
        }
    }
    
    private static func warn(_ message: String) {
        log(level: .warning, message)
    }
    
    private static func debug(_ message: String) {
        log(level: .debug, message)
    }
}
