//
//  DYViewController.swift
//  Dayol-iOS
//
//  Created by 박종상 on 2021/07/11.
//

import UIKit

class DYViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if isIPad {
            return .all
        } else {
            return .portrait
        }
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if isIPad {
            return .landscapeLeft
        } else {
            return .portrait
        }
    }

    deinit { DYLog.d(.deinit, in: Self.self, value: "\(Self.self)") }
}
