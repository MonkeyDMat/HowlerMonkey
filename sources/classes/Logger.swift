//
//  Logger.swift
//  HowlerMonkey
//
//  Created by mathieu lecoupeur on 23/02/2019.
//

import Foundation

public struct LogLevel: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let info = LogLevel(rawValue: 1 << 0)
    public static let warning = LogLevel(rawValue: 1 << 1)
    public static let error = LogLevel(rawValue: 1 << 2)
}

public enum LogDomain: Hashable {
    case network
    case service
    case coordinator
    case ui
    case parsing
    case persistence
    case analytics
    case custom(String)
    case business
    case filesystem
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .network:
            hasher.combine("Network")
        case .service:
            hasher.combine("Service")
        case .coordinator:
            hasher.combine("Coordinator")
        case .ui:
            hasher.combine("UI")
        case .parsing:
            hasher.combine("Parsing")
        case .persistence:
            hasher.combine("Persistence")
        case .analytics:
            hasher.combine("Analytics")
        case .business:
            hasher.combine("Business")
        case .filesystem:
            hasher.combine("FileSystem")
        case .custom(let type):
            hasher.combine(type)
        }
    }
}

public enum LogMetadata: Equatable {
    case level
    case domain
    case file
    case date
    case time
    case method
    case line
    case column
    case separator(String)
    case message
    
    public static func == (lhs: LogMetadata, rhs: LogMetadata) -> Bool {
        switch (lhs, rhs) {
        case (.level, .level),
             (.domain, .domain),
             (.file, .file),
             (.date, .date),
             (.time, .time),
             (.method, .method),
             (.line, .line),
             (.column, .column),
             (.message, .message):
            return true
        case (.separator(let sep1), .separator(let sep2)):
            return sep1 == sep2
        default:
            return false
        }
    }
}

open class Logger {
    private var logLevelIcons: [LogLevel.RawValue: String] = [LogLevel.info.rawValue: "😃",
                                                      LogLevel.warning.rawValue: "⚠️",
                                                      LogLevel.error.rawValue: "❌"]
    private var logDomainIcons: [LogDomain: String] = [LogDomain.analytics: "📈",
                                               LogDomain.business: "🏦",
                                               LogDomain.coordinator: "✈️",
                                               LogDomain.filesystem: "🗂",
                                               LogDomain.network: "🌎",
                                               LogDomain.parsing: "📝",
                                               LogDomain.persistence: "📥",
                                               LogDomain.service: "⚙️",
                                               LogDomain.ui: "🖼"]
    
    private(set) public var format: [LogMetadata]
    
    //MARK: - Initializers
    public init(format: [LogMetadata] = [.message]) {
        self.format = format
        if !format.contains(where: { (metadata) -> Bool in
            return metadata == LogMetadata.message
        }) {
            self.format.append(.message)
        }
    }
    
    public init(format: String) {
        var buffer: String = ""
        var isPlaceholder = false
        
        self.format = []
        
        for i in 0..<format.count {
            let index = format.index(format.startIndex, offsetBy: i)
            let currentChar = format[index]
            if currentChar != "#" {
                buffer.append(currentChar)
            } else {
                if !isPlaceholder {
                    self.format.append(LogMetadata.separator(buffer))
                } else {
                    switch buffer {
                    case "LV":
                        self.format.append(.level)
                    case "D":
                        self.format.append(.domain)
                    case "f":
                        self.format.append(.file)
                    case "d":
                        self.format.append(.date)
                    case "t":
                        self.format.append(.time)
                    case "m":
                        self.format.append(.method)
                    case "l":
                        self.format.append(.line)
                    case "c":
                        self.format.append(.column)
                    case "M":
                        self.format.append(.message)
                    default:
                        ()
                    }
                }
                buffer = ""
                isPlaceholder.toggle()
            }
        }
        if buffer.count != 0 {
            self.format.append(LogMetadata.separator(buffer))
        }
    }
    
    //MARK: - Private Methods
    @discardableResult
    open func log(message: String, logLevel: LogLevel, logDomain: LogDomain?, file: String, method: String, line: Int, column: Int) -> String {
        fatalError("You must override log methods")
    }
}

extension Logger {
    public func getString(for attribute: LogMetadata, logLevel: LogLevel, logDomain: LogDomain?, message: String, file: String, method: String, line: Int, column: Int) -> String {
        switch attribute {
        case .level:
            return getIcon(for: logLevel)
        case .domain:
            return getIcon(for: logDomain)
        case .file:
            return file
        case .date:
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: Date())
        case .time:
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "HH:mm:ss.SSS"
            return formatter.string(from: Date())
        case .method:
            return method
        case .line:
            return "\(line)"
        case .column:
            return "\(column)"
        case .separator(let separator):
            return separator
        case .message:
            return message
        }
    }
}

//MARK: - LogLevel Icons
extension Logger {
    public func getIcon(for logLevel: LogLevel) -> String {
        if let icon = logLevelIcons[logLevel.rawValue] {
            return icon
        }
        
        return ""
    }
    
    public func setIcon(_ icon: String, for level: LogLevel) {
        logLevelIcons[level.rawValue] = icon
    }
}

//MARK: - LogDomain Icons
extension Logger {
    public func getIcon(for logDomain: LogDomain?) -> String {
        guard let logDomain = logDomain else {
            return ""
        }
        switch logDomain {
        case .custom(let icon):
            return icon
        default:
            return logDomainIcons[logDomain] ?? ""
        }
    }
    
    public func setIcon(_ icon: String, for domain: LogDomain) {
        logDomainIcons[domain] = icon
    }
}
