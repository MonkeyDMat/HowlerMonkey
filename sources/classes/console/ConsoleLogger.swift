//
//  ConsoleLogger.swift
//  HowlerMonkey
//
//  Created by mathieu lecoupeur on 23/02/2019.
//

import Foundation

public class ConsoleLogger: Logger {
    
    @discardableResult
    override public func log(message: String, logLevel: LogLevel, logDomain: LogDomain?, file: String, method: String, line: Int, column: Int) -> String {
        var string = ""
        
        for attribute in format {
            let str = getString(for: attribute, logLevel: logLevel, logDomain: logDomain, message: message, file: file, method: method, line: line, column: column)
            string.append(contentsOf: str)
        }
        
        print(string)
        return string
    }
}
