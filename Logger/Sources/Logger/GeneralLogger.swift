import Foundation

/// Standard logger implementation
public class GeneralLogger: LoggerProtocol {

    public let identifier: String
    public var outputLevel: LoggerLevel

    private let showFunctionName: Bool
    private let showFileNames: Bool
    private let showLineNumbers: Bool

    private var outputStream: TextOutputStream

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd'T'HH:mm:ss.SZ"
        return dateFormatter
    }()

    private var _isEnabled: Bool
    
    private let logQueue = DispatchQueue(label: "com.lifelog.logger", qos: .utility, attributes: [], autoreleaseFrequency: .workItem)

    public var isEnabled: Bool {
        get {
            #if DEBUG
                return _isEnabled
            #else
                return false
            #endif
        }
        set {
            _isEnabled = newValue
        }
    }

    /// Create logger instance
    /// - Parameters:
    ///   - identifier: uniq identifier that will be a part of final message
    ///   - enabled: set `true` if logger should log messages
    ///   - outputLevel: logger output level
    ///   - showFunctionName: insert function name in logged messages
    ///   - showFileNames: insert file name in logged messages
    ///   - showLineNumbers: insert line number in logged messages
    ///   - outputStream: output stream for logger. [ConsoleTextOutputStream](x-source-tag://ConsoleTextOutputStream) is used by default.
    public init(
        _ identifier: String,
        enabled: Bool = true,
        outputLevel: LoggerLevel = .debug,
        showFunctionName: Bool = true,
        showFileNames: Bool = true,
        showLineNumbers: Bool = true,
        outputStream: TextOutputStream = ConsoleTextOutputStream()
    ) {
        self.identifier = identifier
        self.outputLevel = outputLevel
        self.showFunctionName = showFunctionName
        self.showFileNames = showFileNames
        self.showLineNumbers = showLineNumbers
        _isEnabled = enabled
        self.outputStream = outputStream
    }

    public func log(
        _ level: LoggerLevel,
        functionName: StaticString,
        fileName: StaticString,
        lineNumber: Int,
        message: () -> Any?
    ) {
        guard shouldLog(level: level),
            let message = message() else {
                return
        }

        let log: String = {
            let fileName: String? = showFileNames ? ("\(fileName)" as NSString).lastPathComponent as String: nil
            let lineNumber: String? = showLineNumbers ? "\(lineNumber)" : nil
            let functionName: String? = showFunctionName ? "\(functionName)" : nil

            let place: String = {
                let components = [fileName, functionName, lineNumber].compactMap { $0 }
                guard !components.isEmpty else {
                    return ""
                }
                return "[\(components.compactMap { $0 }.joined(separator: ": ")))]"
            }()
            return "[\(dateFormatter.string(from: Date()))][\(level.name)]\(place) - \(message)"
        }()
        logQueue.async {
            self.outputStream.write(log)
        }
    }
}
