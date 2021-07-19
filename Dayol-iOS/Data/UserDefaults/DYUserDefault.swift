//
//  DayolUserDefaults.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/05/15.
//

import Foundation

@propertyWrapper
struct DYUserDefault<T> {
    let key: String
    let value: T

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

// MARK: Type
private enum DYUserDefaultsType: String {
    case shouldOnboarding
    case homeListOption
    case deviceToken
    case isMembership
    case activityType
    case subscribeExpireAt
}

enum DYUserDefaults {
    // MARK: Launch Config Infomation
    @DYUserDefault(key: DYUserDefaultsType.shouldOnboarding.rawValue, value: true)
    static var shouldOnboading: Bool
    @DYUserDefault(key: DYUserDefaultsType.homeListOption.rawValue, value: false)
    static var showFavoriteListAtLaunch: Bool
    @DYUserDefault(key: DYUserDefaultsType.deviceToken.rawValue, value: "")
    static var deviceToken: String
    @DYUserDefault(key: DYUserDefaultsType.isMembership.rawValue, value: false)
    static var isMembership: Bool
    @DYUserDefault(key: DYUserDefaultsType.activityType.rawValue, value: 0)
    static var activityType: Int
    @DYUserDefault(key: DYUserDefaultsType.subscribeExpireAt.rawValue, value: 0)
    static var subscribeExpireAt: TimeInterval

    // MARK: ...
}
