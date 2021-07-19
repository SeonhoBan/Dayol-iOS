//
//  MembershipManager.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/07/18.
//

import Foundation
import RxSwift

/// Member Info
struct MembershipInfo {
    let deviceToken: String
    let activityType: UserActivityType
    let expireAt: TimeInterval
    let isMembership: Bool
}

/// Activity Type
enum UserActivityType: Int {
    case new = 0, subscriber, expiredSubscriber
}

final class MembershipManager {
    static let shared = MembershipManager()

    var info: MembershipInfo {
        return MembershipInfo(
            deviceToken: DYUserDefaults.deviceToken,
            activityType: UserActivityType(rawValue:DYUserDefaults.activityType) ?? .new,
            expireAt: DYUserDefaults.subscribeExpireAt,
            isMembership: DYUserDefaults.isMembership
        )
    }

    var isMembership: Bool { info.isMembership }

    var userActivityType: UserActivityType { info.activityType }

    var membershipExpireAt: TimeInterval { info.expireAt }

    var didChangeMembershipType = BehaviorSubject<UserActivityType>(
        value: UserActivityType(rawValue: DYUserDefaults.activityType) ?? .new
    )

    let disposeBag = DisposeBag()

    /// Changed User Activity Type
    func didChangeMembership(response: IAPAutoSubscriptionResponse) {
        DYUserDefaults.subscribeExpireAt = response.expireAt
        DYUserDefaults.activityType = response.activityType.rawValue
        DYUserDefaults.isMembership = response.activityType == .subscriber ? true : false
        didChangeMembershipType.onNext(response.activityType)
    }
}
