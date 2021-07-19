//
//  PencilSettingColorButton.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/07/10.
//

import UIKit
import RxSwift

private enum Design {
    static let bgImage = UIImage(named: "toolbar_imgGradientCircle")
    static let selectedColorDiameter: CGFloat = 26
    static let selectedColorRadius: CGFloat = 13
}

class PencilSettingColorButton: UIView {
    static let preferredSize = CGSize(width: 38, height: 38)
    private(set) var currentColor: UIColor
    let tap = PublishSubject<Void>()

    // MARK: UI Property

    private let bgImageView: UIImageView = {
        let imageView = UIImageView(image: Design.bgImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let selectedColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Design.selectedColorRadius
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override var intrinsicContentSize: CGSize {
        return Self.preferredSize
    }

    // MARK: Init

    init(currentColor: UIColor) {
        self.currentColor = currentColor
        super.init(frame: .zero)
        initView()
        setupConstraints()
        setupGesture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelectedColor(_ color: UIColor) {
        selectedColorView.backgroundColor = color
    }
}

// MARK: - Private Initialize

private extension PencilSettingColorButton {

    func initView() {
        addSubview(bgImageView)
        addSubview(selectedColorView)
        setSelectedColor(currentColor)
    }

    func setupConstraints() {

        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: topAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            selectedColorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectedColorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedColorView.widthAnchor.constraint(equalToConstant: Design.selectedColorDiameter),
            selectedColorView.heightAnchor.constraint(equalToConstant: Design.selectedColorDiameter)
        ])
    }
}

// MARK: - Tap

private extension PencilSettingColorButton {

    func setupGesture() {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(didTapColorButton))
        addGestureRecognizer(recognizer)
    }

    @objc func didTapColorButton() {
        tap.onNext(())
    }
}
