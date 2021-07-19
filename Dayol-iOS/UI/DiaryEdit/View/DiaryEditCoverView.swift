//
//  DiaryEditCoverView.swift
//  Dayol-iOS
//
//  Created by 박종상 on 2021/01/04.
//

import UIKit
import RxSwift
import RxCocoa

private enum Design {
    static let maximumZoomIn: CGFloat = 2.0
    static let minimumZoomOut: CGFloat = 1.0
    
    static let coverCenterY: CGFloat = 30.0
    
    static let zoomLabelBottom: CGFloat = 30.0
    static let zoomLabelFont = UIFont.appleMedium(size: 14)
    static let zoomLabelTextColor: UIColor = UIColor.gray700
    static let zoomLabelSpace: CGFloat = -0.26

    static let defaultCoverSize: CGSize = DiaryView.defaultCoverSize
    static var coverSize: CGSize {
        if isIPad == false {
            if UIScreen.main.bounds.size.height <= 667 {
                return CGSize(width: defaultCoverSize.width * 0.7, height: defaultCoverSize.height * 0.7)
            }

            return defaultCoverSize
        }

        if [UIDeviceOrientation.portrait, .portraitUpsideDown].contains(UIDevice.current.orientation) {
            return CGSize(width: defaultCoverSize.width * 2.0, height: defaultCoverSize.height * 2.0)
        }

        return defaultCoverSize
    }

}

private enum Text {
    static let zoomText = "두 손으로 확대/축소 할 수 있어요!"
}

class DiaryEditCoverView: UIView {

    private let disposeBag = DisposeBag()
    var didTappedLocker: Observable<Void> {
        return diaryView.didTappedLocker.asObservable()
    }
    // UI Porperty

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = Design.minimumZoomOut
        scrollView.maximumZoomScale = Design.maximumZoomIn
        scrollView.bouncesZoom = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let zoomLabel: UILabel = {
        let label = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Design.zoomLabelFont,
            .kern: Design.zoomLabelSpace
        ]
        let attributedText = NSMutableAttributedString(string: Text.zoomText, attributes: attributes)
        label.textColor = Design.zoomLabelTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = attributedText
        label.sizeToFit()
        
        return label
    }()

    let diaryView: DiaryView = {
        let view = DiaryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setCover(color: .DYBrown)
        return view
    }()

    // Constraints

    var diaryWidthConstraint: NSLayoutConstraint?
    var diaryHeightConstraint: NSLayoutConstraint?
    
    init() {
        super.init(frame: .zero)
        initView()
        bindEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateDiaryConstraints()
        updateScrollViewInset()
    }
    
    func updateDiaryConstraints() {
        diaryWidthConstraint?.constant = Design.coverSize.width
        diaryHeightConstraint?.constant = Design.coverSize.height
    }

    func updateScrollViewInset() {
        let horizontalMargin = (scrollView.frame.width - Design.coverSize.width) / 2.0
        let verticalMargin = (scrollView.frame.height
                                - Design.coverSize.height) / 2.0
        scrollView.contentInset = UIEdgeInsets(top: verticalMargin - Design.coverCenterY,
                                               left: horizontalMargin,
                                               bottom: verticalMargin + Design.coverCenterY,
                                               right: horizontalMargin)
    }

}

extension DiaryEditCoverView {

    private func initView() {
        scrollView.delegate = self
        scrollView.addSubview(diaryView)
        addSubview(scrollView)
        addSubview(zoomLabel)
        setConstraint()
    }

    private func setConstraint() {
        let frameGuide = scrollView.frameLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide
        let diaryWidthConstraint = diaryView.widthAnchor.constraint(equalToConstant: Design.coverSize.width)
        let diaryHeightConstraint = diaryView.heightAnchor.constraint(equalToConstant: Design.coverSize.height)

        NSLayoutConstraint.activate([
            frameGuide.leftAnchor.constraint(equalTo: leftAnchor),
            frameGuide.rightAnchor.constraint(equalTo: rightAnchor),
            frameGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            frameGuide.topAnchor.constraint(equalTo: topAnchor),

            diaryView.rightAnchor.constraint(equalTo: contentGuide.rightAnchor),
            diaryView.leftAnchor.constraint(equalTo: contentGuide.leftAnchor),
            diaryView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            diaryView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
            diaryView.widthAnchor.constraint(equalTo: contentGuide.widthAnchor),
            diaryView.heightAnchor.constraint(equalTo: contentGuide.heightAnchor),

            diaryWidthConstraint,
            diaryHeightConstraint,

            zoomLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            zoomLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Design.zoomLabelBottom)
        ])

        self.diaryWidthConstraint = diaryWidthConstraint
        self.diaryHeightConstraint = diaryHeightConstraint
    }

    private func bindEvent() {
        diaryView.contentsView.currentToolSubject.bind { [weak self] tool in
            guard tool != nil else {
                self?.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1
                return
            }
            self?.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        }
        .disposed(by: disposeBag)
    }

}

extension DiaryEditCoverView {

    var asThumbnail: UIImage? {
        scrollView.zoomScale = Design.minimumZoomOut
        return diaryView.asImage()
    }

    func setCoverColor(color: PaletteColor) {
        diaryView.setCover(color: color)
    }
    
    func setDayolLogoHidden(_ isHidden: Bool) {
        diaryView.setDayolLogoHidden(isHidden)
    }

    func setCoverLock(isLock: Bool) {
        UIView.transition(with: diaryView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.diaryView.isLock = isLock
        }, completion: nil)
    }

}

extension DiaryEditCoverView: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return diaryView
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.panGestureRecognizer.isEnabled = false
        zoomLabel.isHidden = true
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.panGestureRecognizer.isEnabled = true

        if scale == 1.0 {
            zoomLabel.isHidden = false
        }
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }

}
