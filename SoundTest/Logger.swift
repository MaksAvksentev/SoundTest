//
//  Logger.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 11.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import Foundation
import CocoaLumberjack

enum LogModule: Int, CustomStringConvertible {
    case HTTP
    case CoreData
    case JSON
    case UI
    case none
    
    var description: String {
        switch self {
        case .HTTP:
            return "HTTP    "
        case .CoreData:
            return "CoreData"
        case .JSON:
            return "JSON    "
        case .UI:
            return "UI      "
        case .none:
            return "None    "
        }
    }
}



let log = Logger()

class Logger {
    
    
    /**
     Console text colors for all log levels. For defining colors was used extension of UIColor: init?(hexString: String)
     */
    fileprivate struct ConsoleColor {
        let verbose  =  UIColor.black
        let debug    =  UIColor.black
        let info     =  UIColor.black
        let warning  =  UIColor.yellow
        let error    =  UIColor.red
    }
    
    
    /**
     Default initialiser for logger.
     
     @see: https://github.com/CocoaLumberjack/CocoaLumberjack
     */
    func setupSharedLogInstance() {
        
        DDLog.add(DDTTYLogger.sharedInstance) // TTY = Xcode console
        DDLog.add(DDASLLogger.sharedInstance) // ASL = Apple System Logs
        
        let fileLogger = DDFileLogger()
        fileLogger?.rollingFrequency = TimeInterval(60 * 60 * 24) // 24 hours
        fileLogger?.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger!, with: DDLogLevel.info) // Log to file
        
        self.setUpConsoleColors()
    }
    
    
    /**
     Console color works based on XcodeColors.
     
     - @see: https://github.com/robbiehanson/XcodeColors
     */
    fileprivate func setUpConsoleColors () {
        
        DDTTYLogger.sharedInstance.colorsEnabled = true
        
        //Check if XcodeColors target environment variable is defined
        let xcode_colors = getenv("XcodeColors")
        
        //Check if XcodeColors plugin is activated
        if (xcode_colors != nil && strcmp(xcode_colors, "YES") == 0) {
            DDTTYLogger.sharedInstance.setForegroundColor(ConsoleColor().verbose, backgroundColor: UIColor.white, for: .verbose)
            DDTTYLogger.sharedInstance.setForegroundColor(ConsoleColor().debug,   backgroundColor: UIColor.white, for: .debug)
            DDTTYLogger.sharedInstance.setForegroundColor(ConsoleColor().info,    backgroundColor: UIColor.white, for: .info)
            DDTTYLogger.sharedInstance.setForegroundColor(ConsoleColor().warning, backgroundColor: UIColor.white, for: .warning)
            DDTTYLogger.sharedInstance.setForegroundColor(ConsoleColor().error,   backgroundColor: UIColor.white, for: .error)
        }
    }
    
    
    /**
     Log content representation. Logger representation works only with String and NSError types
     
     - parameter logObject: Object for representation
     - returns: String representation of sended sended params
     */
    fileprivate func generateLogRepresentation(_ logObject: Any) -> String {
        
        let stringRepresentation: String
        
        if let stringObject = logObject as? String {
            stringRepresentation = "String: \(stringObject)"
        } else if let errorObject = logObject as? NSError {
            stringRepresentation = "Error: \(errorObject.code). \(errorObject.localizedDescription)"
        } else {
            fatalError("MTLogger only works for values that conform to String or NSError")
        }
        
        return stringRepresentation
    }
    
    
    /**
     Generate final log representation
     
     - parameter logObject:    Input log data parameter. MTLogger works only with String and NSError types
     - parameter levelLabel:   Level description. Preferable uppercase string with 5 characters
     - parameter module:       Representation module is enum item from LogModule. Describe logistics for displayed log
     - parameter fileName:     File name, where log method was called from
     - parameter lineNumber:   Line number, where log method was called from
     - parameter functionName: Function name, where log method was called from
     
     - returns: Final log representation string
     */
    fileprivate func generateLogDescription(_ logObject: Any, levelLabel: String, module: LogModule, fileName: String, lineNumber: Int, functionName: String) -> String? {
        
        let stringRepresentation: String = self.generateLogRepresentation(logObject)
        
        let fileURL = NSURL(fileURLWithPath: fileName).standardized?.lastPathComponent ?? "Unknown file"
        
        let threadLevel = Thread.isMainThread ? "UI" : "BG"
        
        return "\(levelLabel) | \(threadLevel) | \(module.description) | \(fileURL):\(lineNumber) [\(functionName)] \(stringRepresentation)"
    }
    
    
    /**
     Display String object in console log with VERBOSE log-level. This level is displayed in DEBUG mode only
     
     - parameter object:       Input string parameter. MTLogger().verbose display only String log data
     - parameter module:       Representation module is enum item from LogModule. Describe logistics for displayed log
     - parameter fileName:     File name, where log method was called from
     - parameter lineNumber:   Line number, where log method was called from
     - parameter functionName: Function name, where log method was called from
     */
    func verbose(_ object: String, LogModule module: LogModule = .none, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
        #if DEBUG
            if let verboseLogStack = self.generateLogDescription(object, levelLabel: "VERBOSE", module: module, fileName: fileName, lineNumber: lineNumber, functionName: functionName) {
                
                DDLogError(verboseLogStack)
                
            }
        #endif
    }
    
    
    /**
     Display String object in console log with DEBUG log-level. This level is displayed in DEBUG mode only
     
     - parameter object:       Input string parameter. MTLogger().debug display only String log data
     - parameter module:       Representation module is enum item from LogModule. Describe logistics for displayed log
     - parameter fileName:     File name, where log method was called from
     - parameter lineNumber:   Line number, where log method was called from
     - parameter functionName: Function name, where log method was called from
     */
    func debug(_ object: String, LogModule module: LogModule = .none, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
        #if DEBUG
            if let debugLogStack = self.generateLogDescription(object, levelLabel: "DEBUG", module: module, fileName: fileName, lineNumber: lineNumber, functionName: functionName) {
                
                DDLogDebug(debugLogStack)
                
            }
        #endif
    }
    
    
    /**
     Display String object in console log with INFO log-level. This level is displayed in DEBUG mode only
     
     - parameter object:       Input string parameter. MTLogger().info display only String log data
     - parameter module:       Representation module is enum item from LogModule. Describe logistics for displayed log
     - parameter fileName:     File name, where log method was called from
     - parameter lineNumber:   Line number, where log method was called from
     - parameter functionName: Function name, where log method was called from
     */
    func info(_ object: String, LogModule module: LogModule = .none, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
        #if DEBUG
            if let infoLogStack = self.generateLogDescription(object, levelLabel: "INFO ", module: module, fileName: fileName, lineNumber: lineNumber, functionName: functionName) {
                
                DDLogInfo(infoLogStack)
                
            }
        #endif
    }
    
    
    /**
     Display String object in console log with ERROR log-level.
     
     - parameter object:       Input error data. MTLogger().error display String or NSError objects as well
     - parameter module:       Representation module is enum item from LogModule. Describe logistics for displayed log
     - parameter fileName:     File name, where log method was called from
     - parameter lineNumber:   Line number, where log method was called from
     - parameter functionName: Function name, where log method was called from
     */
    func error(_ object: Any, LogModule module: LogModule = .none, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        if let errorLogStack = self.generateLogDescription(object, levelLabel: "ERROR", module: module, fileName: fileName, lineNumber: lineNumber, functionName: functionName) {
            
            DDLogError(errorLogStack)
            
        }
    }
    
    
    /**
     Display String object in console log with WARNING log-level. This level is displayed in DEBUG mode only
     
     - parameter object:       Input string parameter. MTLogger().warning display only String log data
     - parameter module:       Representation module is enum item from LogModule. Describe logistics for displayed log
     - parameter fileName:     File name, where log method was called from
     - parameter lineNumber:   Line number, where log method was called from
     - parameter functionName: Function name, where log method was called from
     */
    func warning(_ object: String, LogModule module: LogModule = .none, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
        #if DEBUG
            if let warningLogStack = self.generateLogDescription(object, levelLabel: "WARNING", module: module, fileName: fileName, lineNumber: lineNumber, functionName: functionName) {
                
                DDLogWarn(warningLogStack)
                
            }
        #endif
    }
}
