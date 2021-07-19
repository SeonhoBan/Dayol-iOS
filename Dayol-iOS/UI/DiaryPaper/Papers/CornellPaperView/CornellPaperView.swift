//
//  CornellPaperView.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/01/27.
//

import UIKit
import RxSwift

private enum Design {
    static let redLineColor = UIColor(decimalRed: 226, green: 88, blue: 88)
    static let headerSeparatorColor = UIColor.gray800
    static let lineColor = UIColor(decimalRed: 233, green: 233, blue: 233)

    static let lineWidth: CGFloat = 1
    static let lineHeight: CGFloat = 30.0

    static func titleAreaHeight(orentation: Paper.PaperOrientation) -> CGFloat {
        switch orentation {
        case .landscape: return 50.0
        case .portrait: return 64.0
        }
    }

    static func redLineOriginX(orentation: Paper.PaperOrientation) -> CGFloat {
        switch orentation {
        case .landscape: return 200.0
        case .portrait: return 100.0
        }
    }

    static func numberOfLineInPage(orientation: Paper.PaperOrientation, isFirstPage: Bool) -> Int {
        let paperSize = PaperOrientationConstant.size(orentantion: orientation)
        if isFirstPage {
            return Int(paperSize.height - titleAreaHeight(orentation: orientation) / Self.lineHeight) + 1
        } else {
            return Int(paperSize.height / Self.lineHeight) + 1
        }
    }
}

class CornellPaperView: BasePaper {
    private let cornellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private(set) var isFirstPage: Bool = true
    
    override func configure(viewModel: PaperViewModel, orientation: Paper.PaperOrientation) {
        super.configure(viewModel: viewModel, orientation: orientation)
        cornellImageView.image = getCornellImage(isFirstPage: isFirstPage)
        cornellImageView.contentMode = .topLeft
        contentView.addSubViewPinEdge(cornellImageView)
    }
}

private extension CornellPaperView {
    func getCornellImage(isFirstPage: Bool) -> UIImage? {
        guard let orientation = self.orientation else { return nil }

        let paperSize = PaperOrientationConstant.size(orentantion: orientation)
        UIGraphicsBeginImageContextWithOptions(paperSize, false, 0.0)

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        context.setLineWidth(Design.lineWidth)
        context.setLineCap(.square)

        // MARK: Draw Each base Line

        context.setStrokeColor(Design.lineColor.cgColor)

        let positionMargin = isFirstPage ? Design.titleAreaHeight(orentation: orientation) : 0

        for row in 0..<Design.numberOfLineInPage(orientation: orientation, isFirstPage: isFirstPage) + 1 {
            let positionY = row * Int(Design.lineHeight) + Int(positionMargin)
            let startPoint = CGPoint(x: 0, y: positionY)
            let endPoint = CGPoint(x: Int(paperSize.width), y: positionY)

            context.move(to: startPoint)
            context.addLine(to: endPoint)
        }

        context.strokePath()

        // MARK: Draw Red Line

        context.setStrokeColor(Design.redLineColor.cgColor)

        let positionX = Design.redLineOriginX(orentation: orientation)
        let startPoint = CGPoint(x: positionX, y: positionMargin)
        let endPoint = CGPoint(x: positionX, y: paperSize.height)

        context.move(to: startPoint)
        context.addLine(to: endPoint)

        context.strokePath()

        // MARK: Draw Header If Needed

        if isFirstPage {
            context.setStrokeColor(Design.headerSeparatorColor.cgColor)

            let positionY = Design.titleAreaHeight(orentation: orientation)
            let startPoint = CGPoint(x: 0, y: positionY)
            let endPoint = CGPoint(x: paperSize.width, y: positionY)

            context.move(to: startPoint)
            context.addLine(to: endPoint)

            context.strokePath()
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
