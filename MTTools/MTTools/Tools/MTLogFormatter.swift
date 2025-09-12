//
//  MTLogFormatter.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import Foundation
import CocoaLumberjackSwift

/// 日志格式
class MTLogFormatter: NSObject {
    
    /// 日期格式
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    /// 开启自定义日志
    static func startLog() {
        #if DEBUG
        // 控制台输出
        DDOSLogger.sharedInstance.logFormatter = MTLogFormatter()
        DDLog.add(DDOSLogger.sharedInstance, with: .all)
        #else
        
        #endif
        // 文件输出
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        let logDirectory = documents.appendingPathComponent("Logs")
        
        let fileManager = MTLogFileManager(logsDirectory: logDirectory, fileName: "MTDemo")
        let fileLogger = DDFileLogger(logFileManager: fileManager)
        fileLogger.logFormatter = MTLogFormatter()
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        fileLogger.maximumFileSize = 0
        
        DDLog.add(fileLogger, with: .all)
    }
}

// MARK: - DDLogFormatter
extension MTLogFormatter: DDLogFormatter {
    /// 日志输出
    func format(message logMessage: DDLogMessage) -> String? {
        var logLevel: String = "[Error]"
        
        switch logMessage.flag {
        case .error:
            logLevel = "[Error]"
        case .warning:
            logLevel = "[Warning]"
        case .info:
            logLevel = "[Info]"
        case .debug:
            logLevel = "[Debug]"
        default:
            logLevel = "[Verbose]"
        }
        
        let dateAndTime: String = dateFormatter.string(from: logMessage.timestamp)
        let message: String = String(format: "%@ %@ %@ <line:%li>: %@\n\n", dateAndTime, logLevel, logMessage.fileName, logMessage.line, logMessage.message)
        
        return message
    }
}

// MARK: - 文件写入
fileprivate class MTLogFileManager: DDLogFileManagerDefault {
    
    /// 日期格式
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    private var fileName: String = ""
    
    override init(logsDirectory: String?) {
        super.init(logsDirectory: logsDirectory)
    }
    
    convenience init(logsDirectory: String?, fileName: String?) {
        self.init(logsDirectory: logsDirectory)
        self.fileName = fileName ?? ""
        if self.fileName.isEmpty {
            guard let infoDictionary = Bundle.main.infoDictionary else {
                return
            }
            guard let bundleName = infoDictionary["CFBundleName"] as? String else {
                return
            }
            self.fileName = bundleName
        }
    }
    
    override var newLogFileName: String {
        get {
            return String(format: "%@_%@.log", fileName, dateFormatter.string(from: Date()))
        }
    }
    
    override func isLogFile(withName fileName: String) -> Bool {
        return fileName.hasSuffix(".log")
    }
}

// MARK: - FUNC

func MTError(_ message: @autoclosure () -> DDLogMessageFormat, level: DDLogLevel = .all, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = asyncLoggingEnabled, ddlog: DDLog = .sharedInstance) {
    _DDLogMessage(message(), level: level, flag: .error, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}

func MTWarning(_ message: @autoclosure () -> DDLogMessageFormat, level: DDLogLevel = .all, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = asyncLoggingEnabled, ddlog: DDLog = .sharedInstance) {
    _DDLogMessage(message(), level: level, flag: .warning, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}

func MTInfo(_ message: @autoclosure () -> DDLogMessageFormat, level: DDLogLevel = .all, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = asyncLoggingEnabled, ddlog: DDLog = .sharedInstance) {
    _DDLogMessage(message(), level: level, flag: .info, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}

func MTDebug(_ message: @autoclosure () -> DDLogMessageFormat, level: DDLogLevel = .all, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = asyncLoggingEnabled, ddlog: DDLog = .sharedInstance) {
    _DDLogMessage(message(), level: level, flag: .debug, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}

func MTVerbose(_ message: @autoclosure () -> DDLogMessageFormat, level: DDLogLevel = .all, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = asyncLoggingEnabled, ddlog: DDLog = .sharedInstance) {
    _DDLogMessage(message(), level: level, flag: .verbose, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
}

