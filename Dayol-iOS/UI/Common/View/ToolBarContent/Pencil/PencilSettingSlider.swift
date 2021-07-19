//
//  PencilSettingSlider.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/07/12.
//

import UIKit

private enum Design {
    static let backgroundImage = UIImage(named: "toolBar_color_detail_alpha_bg")
}

class PencilSettingSlider: UISlider {

    private let trackSize: CGSize

    init(trackSize: CGSize) {
        self.trackSize = trackSize
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = trackSize.height
        newBounds.origin.y = newBounds.height / 2 - trackSize.height / 2
        return newBounds
    }

    func setGradient(baseColor: UIColor) {
        let startColor = baseColor.withAlphaComponent(0)
        let endColor = baseColor

        let contentsLayer = CALayer()
        contentsLayer.contents = Design.backgroundImage?.cgImage
        contentsLayer.frame.size = trackSize

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = trackSize
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint.init(x:0.0, y:0.5)
        gradientLayer.endPoint = CGPoint.init(x:1.0, y:0.5)
        gradientLayer.cornerRadius = 8.0
        gradientLayer.isOpaque = false

        contentsLayer.addSublayer(gradientLayer)

        UIGraphicsBeginImageContextWithOptions(contentsLayer.frame.size, contentsLayer.isOpaque, 0.0);

        guard let currentContext = UIGraphicsGetCurrentContext() else { return }
        contentsLayer.render(in: currentContext)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()

            image.resizableImage(withCapInsets: UIEdgeInsets.zero)

            setMaximumTrackImage(image, for: .normal)
            setMinimumTrackImage(image, for: .normal)
        }
    }

}
