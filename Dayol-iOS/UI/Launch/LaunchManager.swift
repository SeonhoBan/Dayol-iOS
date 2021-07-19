//
//  Manager.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/05/15.
//

import Foundation
import Firebase
import GoogleMobileAds
import CoreData
import RxSwift

final class LaunchManager {
    enum Result {
        case beta
        case prod
    }

    var shouldOnboarding: Bool {
        set {
            DYUserDefaults.shouldOnboading = newValue
        }
        get {
            return DYUserDefaults.shouldOnboading
        }
    }

    var launchConfig: Single<Void> {
        return Single.just(Void()) // 약관
            .map { _ in
                FirebaseApp.initialize()
                PersistentManager.shared.saveContext()
                GADManager.mobileAdsStart()
            }
            .flatMap { _ -> Single<Void> in
                return IAPManager.shared.checkPurchasedAndUpdate()
            }

    }
}
