//
//  Logger.swift
//  MysteryPrismClock
//
//  Created on 11/02/25.
//

#if os(macOS)
import Foundation

/// A simple logger that writes to a file in the Downloads folder
public class FileLogger {
    public static let shared = FileLogger()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private let fileURL: URL?
    private var isLoggingEnabled = false
    
    private init() {
        // For screensavers, use /tmp/ which is always accessible
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let fileName = "MysteryPrismClock-\(timestamp).log"
        let tmpURL = URL(fileURLWithPath: "/tmp/\(fileName)")
        
        let header = "=== MysteryPrismClock Log ===\nStarted: \(Date())\n\n"
        do {
            try header.write(to: tmpURL, atomically: true, encoding: .utf8)
            fileURL = tmpURL
        } catch {
            fileURL = nil
        }
    }
    
    /// Enable logging for the entire session (called on launch if CapsLock is down)
    public func enableLogging() {
        isLoggingEnabled = true
    }
    
    /// Check if logging is currently enabled
    public var loggingEnabled: Bool {
        return isLoggingEnabled
    }
    
    /// Log a message to the file
    public func log(_ message: String, level: LogLevel = .info) {
        // Only log if logging was enabled at launch
        guard isLoggingEnabled else {
            return
        }
        
        guard let fileURL = fileURL else {
            return
        }
        
        let timestamp = dateFormatter.string(from: Date())
        let threadInfo = Thread.isMainThread ? "main" : "bg"
        let logEntry = "[\(timestamp)] [\(threadInfo)] [\(level.rawValue)] \(message)\n"
        
        // Append to file - use FileHandle for reliable appending
        do {
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                if let data = logEntry.data(using: .utf8) {
                    fileHandle.write(data)
                }
                try fileHandle.close()
            } else {
                // File doesn't exist, create it with the entry
                try logEntry.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            // Silently fail - don't want logging errors to crash the app
        }
    }
    
    /// Log timer activity with detailed counts - helps track runaway timers
    public func logTimerActivity(source: String, updateCount: Int, isRunning: Bool) {
        log("TIMER [\(source)]: updateCount=\(updateCount), isRunning=\(isRunning)", level: .debug)
    }
    
    /// Log lifecycle events for tracking object retention
    public func logLifecycle(object: String, event: String, details: String = "") {
        let message = details.isEmpty ? "\(object): \(event)" : "\(object): \(event) - \(details)"
        log("LIFECYCLE: \(message)", level: .info)
    }
    
    /// Log a separator for easier reading
    public func logSeparator(_ label: String = "") {
        let sep = label.isEmpty ? "=" : "=== \(label) ==="
        log(String(repeating: "=", count: 60), level: .info)
        if !label.isEmpty {
            log(sep, level: .info)
            log(String(repeating: "=", count: 60), level: .info)
        }
    }
    
    /// Log levels for different types of messages
    public enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }
}

// Convenience extension for easy logging
public extension FileLogger {
    func debug(_ message: String) {
        log(message, level: .debug)
    }
    
    func info(_ message: String) {
        log(message, level: .info)
    }
    
    func warning(_ message: String) {
        log(message, level: .warning)
    }
    
    func error(_ message: String) {
        log(message, level: .error)
    }
}
#endif // os(macOS)
