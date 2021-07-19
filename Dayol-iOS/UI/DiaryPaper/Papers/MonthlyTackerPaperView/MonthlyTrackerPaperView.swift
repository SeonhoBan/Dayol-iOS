//
//  MonthlyTrackerPaperView.swift
//  Dayol-iOS
//
//  Created by 박종상 on 2021/07/11.
//

import UIKit

private enum Design {
    static func backgroundImage(orientation: Paper.PaperOrientation) -> UIImage? {
        switch orientation {
        case .landscape:
            return UIImage(named: "monthlyTrackerBackgroundLandscape")
        case .portrait:
            return UIImage(named: "monthlyTrackerBackgroundPortrait")
        }
    }
}

final class MonthlyTrackerPaperView: BasePaper {
    private let trackerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    override func configure(viewModel: PaperViewModel, orientation: Paper.PaperOrientation) {
        super.configure(viewModel: viewModel, orientation: orientation)
        trackerImageView.image = Design.backgroundImage(orientation: orientation)
        contentView.addSubViewPinEdge(trackerImageView)
    }
}
