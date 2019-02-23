//
//  Log.swift
//  HowlerMonkey
//
//  Created by mathieu lecoupeur on 23/02/2019.
//

import Foundation

public class Log {
    
    private static var loggers: [Logger] = []
    private static var isDev: (() -> Bool)?
    private static var logLevel: [LogLevel] = [.info, .warning, .error]
    
    public static func setup(loggers: [Logger],
                      logLevel: [LogLevel] = [.info, .warning, .error],
                      isDev: @escaping () -> Bool) {
        Log.loggers = loggers
        Log.logLevel = logLevel
        Log.isDev = isDev
    }
    
    public static func addLogger(logger: Logger) {
        loggers.append(logger)
    }
    
    public static func i(_ object: Any,
                  logDomain: LogDomain? = nil,
                  filename: String = #file,
                  line: Int = #line,
                  column: Int = #column,
                  method: String = #function) {
        if isDev?() == true && logLevel.contains(.info) {
            let filename = sourceFileName(filePath: filename)
            
            for logger in loggers {
                logger.log(message: String(describing: object), logLevel: .info, logDomain: logDomain, file: filename, method: method, line: line, column: column)
            }
        }
    }
    
    public static func w(_ object: Any,
                  logDomain: LogDomain? = nil,
                  filename: String = #file,
                  line: Int = #line,
                  column: Int = #column,
                  method: String = #function) {
        if isDev?() == true && logLevel.contains(.warning) {
            let filename = sourceFileName(filePath: filename)
            
            for logger in loggers {
                logger.log(message: String(describing: object), logLevel: .warning, logDomain: logDomain, file: filename, method: method, line: line, column: column)
            }
        }
    }
    
    public static func e(_ object: Any,
                  logDomain: LogDomain? = nil,
                  filename: String = #file,
                  line: Int = #line,
                  column: Int = #column,
                  method: String = #function) {
        if isDev?() == true && logLevel.contains(.error) {
            let filename = sourceFileName(filePath: filename)
            
            for logger in loggers {
                logger.log(message: String(describing: object), logLevel: .error, logDomain: logDomain, file: filename, method: method, line: line, column: column)
            }
        }
    }
    
    private static func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}
