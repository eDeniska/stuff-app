import Foundation

/// Text output stream that allows to write output too few inner outputs
public struct CompoundTextOutputStream: TextOutputStream {

    /// Inner output streams
    public var outputStreams: [TextOutputStream]

    /// Create compound text output stream
    /// - Parameter writers: output streams to which we should write messages.
    public init(outputStreams: [TextOutputStream]) {
        self.outputStreams = outputStreams
    }

    public mutating func write(_ message: String) {
        outputStreams = outputStreams.map {
            var outputStream = $0
            outputStream.write(message)
            return outputStream
        }
    }
}
