//
//  Logger.swift
//  MysteryPrismClock
//
//  Created on 11/02/25.
//

import AppKit

/// A simple logger that writes to a file in the Downloads folder
public class FileLogger {
    public static let shared = FileLogger()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private var fileURL: URL?
    private var isLoggingEnabled = false
    private var hasWrittenHeader = false
    private var currentSessionFileURL: URL?
    
    private init() {
        // Don't create file URL yet - wait until we know if logging is enabled
    }
    
    /// Write the log file header (called lazily on first log message)
    private func writeHeaderIfNeeded() {
        guard !hasWrittenHeader, let fileURL = fileURL else { return }
        hasWrittenHeader = true
        
        let header = "=== MysteryPrismClock Log ===\nStarted: \(Date())\n\n"
        do {
            try header.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            // Silently fail
        }
    }
    
    /// Set logging state based on current Caps Lock state (called on each screensaver launch)
    public func updateLoggingState() {
        let wasEnabled = isLoggingEnabled
        isLoggingEnabled = NSEvent.modifierFlags.contains(.capsLock)
        
        // Only create a new file if we're transitioning from disabled to enabled
        // or if we don't have a file yet and logging is enabled
        if isLoggingEnabled && (!wasEnabled || fileURL == nil) {
            // Create a new log file for this session
            let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
            let fileName = "MysteryPrismClock-\(timestamp).log"
            fileURL = URL(fileURLWithPath: "/tmp/\(fileName)")
            hasWrittenHeader = false
        } else if !isLoggingEnabled && wasEnabled {
            // Transitioning from enabled to disabled - clear the file URL
            fileURL = nil
            hasWrittenHeader = false
        }
        // If already enabled and staying enabled, keep the same file
    }
    
    /// Check if logging is currently enabled
    public var loggingEnabled: Bool {
        return isLoggingEnabled
    }
    
    /// Log a message to the file
    public func log(_ message: String, level: LogLevel = .info) {
        // CRITICAL: Double-check that logging is enabled
        // This prevents any stale log calls from writing to old files
        guard isLoggingEnabled else {
            return
        }
        
        // CRITICAL: Ensure we have a valid file URL for THIS session
        guard let fileURL = fileURL else {
            return
        }
        
        // Write header on first log message
        writeHeaderIfNeeded()
        
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
