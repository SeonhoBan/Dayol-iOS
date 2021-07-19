//
//  FBLog.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/06/12.
//

import Firebase

final class FBLog: Analytics {
    enum LogType: String {
        case impression
        case click
        case error

        enum Menu: String {
            case home
            case diary
            case paper
            case sticket
        }
    }

    override class func logEvent(_ name: String, parameters: [String : Any]?) {
        self.setUserID(Config.shared.deviceToken)
        super.logEvent(name, parameters: parameters)
    }

    private static func logging(_ logType: LogType, value: Any) {
        print("\(Date.now) [📤] - [\(logType)] Message: \(value)")
    }

    /// impression
    static func impression(_ key: LogType.Menu, value: Any ) {
        logEvent(LogType.impression.rawValue, parameters: [key.rawValue: value])
        logging(LogType.impression, value: "\([key: value])")
    }

    /// click log
    static func click(_ key: LogType.Menu, value: Any) {
        logEvent(LogType.click.rawValue, parameters: [key.rawValue: value])
        logging(LogType.click, value: "\([key: value])")
    }

    /// error log
    static func error(_ key: LogType.Menu, value: Any) {
        logEvent(LogType.error.rawValue, parameters: [key.rawValue: value])
        logging(LogType.error, value: "\([key: value])")
    }
}

enum DYLog {
    enum LogType: String {
        case info = "🌱"
        case `deinit` = "✂️"
        case debug = "β"
        case coreData = "📒"
        case cloudKit = "☁️"
        case inAppPurchase = "💰"
        case ad = "🏞"
        case api = "💌"
    }

    /// error log
    static func e(_ key: LogType, in name: Any, value: Any) {
        print("\(Date.now) [🩸|\(key.rawValue)] - [ERROR] KEY: \(key) | [\(name)] -> Message: \(value)")
    }

    /// debuging log
    static func d(_ key: LogType, in name: Any, value: Any) {
        #if DEBUG
        print("\(Date.now) [\(key.rawValue)] - [DEBUG] KEY: \(key) | [\(name)] -> Message: \(value)")
        #endif
    }

    static func i(_ key: LogType, in name: Any, value: Any) {
        print("\(Date.now) [\(key.rawValue)] - [INFO] KEY: \(key) | [\(name)] -> Message: \(value)")
    }
}
