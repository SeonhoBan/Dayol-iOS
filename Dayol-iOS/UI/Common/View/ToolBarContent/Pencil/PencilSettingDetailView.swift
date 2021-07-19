//
//  PencilSettingDetailView.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/07/11.
//

import UIKit
import RxCocoa
import RxSwift

private enum Design {
    static let selectedImage = UIImage(named: "toolBar_color_detail_selected")
    static let buttonConatainerSize = CGSize(width: 184, height: 28)
    static let sliderSize = CGSize(width: 184, height: 20)
    static let sliderTrackSize = CGSize(width: 184, height: 18)
    static let contentInset = UIEdgeInsets(top: 8.0, left: 12, bottom: 8.0, right: 12)
    static let contentSpacing: CGFloat = 16.0
    static let sliderMinValue: Float = 0.0
    static let sliderMaxValue: Float = 1.0
}

extension PencilSettingDetailView {
    enum PenType: String {
        static let maxStep = 5

        case pen, pencil, marker

        func image(at index: Int) -> UIImage? {
            guard index < Self.maxStep else { return nil }
            return UIImage(named: "toolBar_color_detail_\(rawValue)\(index + 1)")
        }
    }

    enum Step: Int {
        static let step1Width: CGFloat = 1.0
        static let step2Width: CGFloat = 5.0
        static let step3Width: CGFloat = 10.0
        static let step4Width: CGFloat = 15.0
        static let step5Width: CGFloat = 20.0

        case step1, step2, step3, step4, step5

        var toolWidth: CGFloat {
            switch self {
            case .step1: return Self.step1Width
            case .step2: return Self.step2Width
            case .step3: return Self.step3Width
            case .step4: return Self.step4Width
            case .step5: return Self.step5Width
            }
        }

        init?(toolWidth: CGFloat) {
            switch toolWidth {
            case Self.step1Width: self = .step1
            case Self.step2Width: self = .step2
            case Self.step3Width: self = .step3
            case Self.step4Width: self = .step4
            case Self.step5Width: self = .step5
            default: return nil
            }
        }
    }
}

class PencilSettingDetailView: UIView {

    static var shouldShowPenWidthSetting: Bool {
        // iPad 에선 width 설정이 적용 됨
        if isIPad {
            return true
        }

        // iPhone 에선 iOS 14.0 이상 부터만 width 설정이 적용 됨
        if #available(iOS 14.0, *) {
            return true
        }

        return false
    }
    static var preferredSize: CGSize {
        if shouldShowPenWidthSetting {
            return CGSize(width: 208, height: 86)
        }
        return CGSize(width: 208, height: 32)
    }
    private var drawTool: DYDrawTool {
        didSet { currentToolSubject.onNext(drawTool) }
    }
    private var penType: PenType? {
        switch drawTool {
        case is DYPenTool: return .pen
        case is DYMarkerTool: return .marker
        case is DYPencilTool: return .pencil
        default: return nil
        }
    }
    private var currentColor: UIColor {
        return drawTool.color
    }
    private let disposeBag = DisposeBag()
    let currentToolSubject = PublishSubject<DYDrawTool>()

    // MARK: UI Property

    private lazy var stepButtons: [UIButton] = {
        var buttonArray: [UIButton] = []

        (0..<PenType.maxStep).forEach {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setBackgroundImage(penType?.image(at: $0), for: .normal)
            button.setImage(Design.selectedImage, for: .selected)
            buttonArray.append(button)
        }
        return buttonArray
    }()

    private let buttonContrainer: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let alphaSlider: PencilSettingSlider = {
        let slider = PencilSettingSlider(trackSize: Design.sliderTrackSize)
        slider.maximumTrackTintColor = .clear
        slider.minimumTrackTintColor = .clear
        slider.minimumValue = Design.sliderMinValue
        slider.maximumValue = Design.sliderMaxValue
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = Design.contentSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        alphaSlider.setGradient(baseColor: currentColor)
    }

    // MARK: Init

    init(drawTool: DYDrawTool) {
        self.drawTool = drawTool
        super.init(frame: .zero)
        initView()
        setupConstraints()
        updateCurrentState()
        bindEvent()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

// MARK: - Private Initialize

private extension PencilSettingDetailView {

    func initView() {
        if Self.shouldShowPenWidthSetting {
            stepButtons.forEach { buttonContrainer.addArrangedSubview($0) }
            contentStackView.addArrangedSubview(buttonContrainer)
        }
        contentStackView.addArrangedSubview(alphaSlider)

        addSubview(contentStackView)
        backgroundColor = .white
    }

    func setupConstraints() {
        if Self.shouldShowPenWidthSetting {
            NSLayoutConstraint.activate([
                buttonContrainer.widthAnchor.constraint(equalToConstant: Design.buttonConatainerSize.width),
                buttonContrainer.heightAnchor.constraint(equalToConstant: Design.buttonConatainerSize.height)
            ])
        }

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: Design.contentInset.top),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Design.contentInset.left),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Design.contentInset.right),

            alphaSlider.widthAnchor.constraint(equalToConstant: Design.sliderSize.width),
            alphaSlider.heightAnchor.constraint(equalToConstant: Design.sliderSize.height)
        ])
    }

    func bindEvent() {
        stepButtons.enumerated().forEach { index, button in
            button.rx.tap.bind { [weak self] in
                self?.stepButtons.forEach { $0.isSelected = false }
                button.isSelected = true

                if let step = Step(rawValue: index) {
                    let newWidth = step.toolWidth
                    self?.drawTool.width = newWidth
                }
            }
            .disposed(by: disposeBag)
        }

        alphaSlider.rx.value
            .bind { [weak self] alpha in
                guard let self = self else { return }
                self.drawTool.alpha = CGFloat(alpha)
            }
            .disposed(by: disposeBag)
    }

    func updateCurrentState() {
        let alpha = drawTool.alpha
        alphaSlider.setValue(Float(alpha), animated: false)

        guard Self.shouldShowPenWidthSetting else { return }
        if let step = Step(toolWidth: drawTool.width) {
            stepButtons[safe: step.rawValue]?.isSelected = true
        }
    }

}
