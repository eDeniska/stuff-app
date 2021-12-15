import Foundation

public enum Logger {
    public static let `default`: LoggerProtocol = GeneralLogger("com.tazetdinov.stuff-app.log", enabled: true, outputStream: CompoundTextOutputStream(outputStreams: [
        ConsoleTextOutputStream(),
        // FileTextOutputStream(name: "stuff-app.log")
    ]))
}
