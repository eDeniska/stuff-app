import Foundation

/// Target of text-streaming operations that write to file.
/// - Tag: FileTextOutputStream
public final class FileTextOutputStream: TextOutputStream {

    /// Default text output stream
    public static var shared = FileTextOutputStream()

    private let path: URL
    private let name: String

    /// URL to file with logs
    public let url: URL

    private static let queue = DispatchQueue(label: "com.tazetdinov.stuff-app.logger", qos: .utility)

    private lazy var fileHandle: FileHandle? = {
        do {
            let url = path.appendingPathComponent(name)
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: url.path) {
                try fileManager.createDirectory(at: path, withIntermediateDirectories: true)

                guard fileManager.createFile(atPath: url.path, contents: nil, attributes: nil) else {
                    print("Can't create file: \(url). Continue to log in console")
                    return nil
                }
            }
            return try FileHandle(forWritingTo: url)
        } catch {
            print("\(error) Continue to log in console")
            return nil
        }
    }()

    /// Create text output stream.
    /// - Parameters:
    ///   - path: path to log file. Optional
    ///   - name: log file name. Optional
    public init(
        path: URL = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!.appendingPathComponent("Logs"),
        name: String = "log.txt"
    ) {
        self.name = name
        self.path = path
        url = path.appendingPathComponent(name)
    }

    public func write(_ message: String) {
        Self.queue.async {
            guard let fileHandle = self.fileHandle else {
                print(message)
                return
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(message.appending("\n").data(using: .utf8)!)
        }
    }

    deinit {
        fileHandle?.closeFile()
    }
}
