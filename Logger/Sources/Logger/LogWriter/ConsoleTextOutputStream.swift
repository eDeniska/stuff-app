import Foundation

/// Target of text-streaming operations that write to console.
/// - Tag: ConsoleTextOutputStream
public struct ConsoleTextOutputStream: TextOutputStream {

    public init() {
    }

    public func write(_ string: String) {
        print(string)
    }
}
