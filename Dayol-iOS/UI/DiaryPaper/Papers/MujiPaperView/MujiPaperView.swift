//
//  MujiPaperView.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/01/20.
//

import UIKit

class MujiPaperView: BasePaper {
    override var identifier: String { MujiPaperView.className }

    private let mujiView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    override func configure(viewModel: PaperViewModel, orientation: Paper.PaperOrientation) {
        super.configure(viewModel: viewModel, orientation: orientation)

        contentView.addSubViewPinEdge(mujiView)
    }
}

