import Foundation

/// Enum defining our log levels
public enum LoggerLevel: Int, Comparable {
    case debug
    case info
    case warning
    case error

    public static func < (lhs: LoggerLevel, rhs: LoggerLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Level name
    public var name: String {
        switch self {
        case .debug:
            return "Debug"
        case .info:
            return "Info"
        case .warning:
            return "Warning"
        case .error:
            return "Error"
        }
    }
}

// Type that describes logger
public protocol LoggerProtocol: AnyObject {

    /// `true` if logger can log messages, otherwise `false`
    var isEnabled: Bool { get set }

    /// Logger identifier
    var identifier: String { get }

    /// The log level of this logger, any logs received at this level or higher will be output to the destinations
    var outputLevel: LoggerLevel { get set }

    /// Log something.
    ///
    /// - Parameters:
    ///     - level:        Log level.
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///     - message:      A closure that returns the object to be logged.
    func log(
        _ level: LoggerLevel,
        functionName: StaticString,
        fileName: StaticString,
        lineNumber: Int,
        message: () -> Any?
    )

    /// Log something.
    ///
    /// - Parameters:
    ///     - level:        Log level.
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///     - message:      A closure that returns the object to be logged.
    func log(
        _ level: LoggerLevel,
        functionName: StaticString,
        fileName: StaticString,
        lineNumber: Int,
        _ message: @autoclosure () -> Any?
    )
}

public extension LoggerProtocol {

    /// Log something.
    ///
    /// - Parameters:
    ///     - level:        Log level.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///     - message:      A closure that returns the object to be logged.
    func log(
        _ level: LoggerLevel,
        fileName: StaticString = #file,
        functionName: StaticString = #function,
        lineNumber: Int = #line,
        message: () -> Any?
    ) {
        log(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, message: message)
    }

    /// Log something.
    ///
    /// - Parameters:
    ///     - level:        Log level.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///     - message:      A closure that returns the object to be logged.
    func log(
        _ level: LoggerLevel,
        functionName: StaticString,
        fileName: StaticString,
        lineNumber: Int,
        _ message: @autoclosure () -> Any?
    ) {
        log(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, message: message)
    }

    /// Log something.
    ///
    /// - Parameters:
    ///     - level:        Log level.
    ///     - functionName: Normally omitted **Default:** *#function*.
    ///     - fileName:     Normally omitted **Default:** *#file*.
    ///     - lineNumber:   Normally omitted **Default:** *#line*.
    ///     - message:      A closure that returns the object to be logged.
    func log(
        _ level: LoggerLevel,
        fileName: StaticString = #file,
        functionName: StaticString = #function,
        lineNumber: Int = #line,
        _ message: @autoclosure () -> Any?
    ) {
        log(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, message: message)
    }

    /// Check if logger should log messages with provided level.
    /// - Parameter level: level to check.
    /// - Returns: true if message for provided level should be logged.
    func shouldLog(level: LoggerLevel) -> Bool {
        isEnabled && outputLevel <= level
    }
}
