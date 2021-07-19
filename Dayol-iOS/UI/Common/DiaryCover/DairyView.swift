//
//  DairyView.swift
//  Dayol-iOS
//
//  Created by 박종상 on 2020/12/22.
//

import UIKit
import PencilKit
import RxSwift

private enum Design {
    enum Standard {
        static let width: CGFloat = 552.0
        static let lockerMargin: CGFloat = 16.0
        static let lockerSize = CGSize(width: 140, height: 120)
    }
}

class DiaryView: UIView, Undoable {
    static let defaultCoverSize: CGSize = CGSize(width: 270, height: 360)

    private let disposeBag = DisposeBag()
    let didTappedLocker = PublishSubject<Void>()

    // MARK: - UI Properties

    private let coverView = DiaryCoverView()
    private let lockerView = DiaryLockerView()

    private var lockerMarginConstraint: NSLayoutConstraint?
    private var lockerWidthConstraint: NSLayoutConstraint?
    private var lockerHeightConstraint: NSLayoutConstraint?

    var contentsView = DYContentsView()

    var hasLogo: Bool = false
    var isLock: Bool = false {
        didSet {
            guard isLock else {
                lockerView.unlock()
                return
            }
            lockerView.lock()
        }
    }
	
    init() {
		super.init(frame: .zero)
        initView()
        setConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func layoutSubviews() {
        typealias Const = Design.Standard
        super.layoutSubviews()
        let ratio = frame.width / Const.width
        lockerMarginConstraint?.constant = Const.lockerMargin * ratio
        lockerWidthConstraint?.constant = Const.lockerSize.width * ratio
        lockerHeightConstraint?.constant = Const.lockerSize.height * ratio
    }

    private func initView() {
        coverView.translatesAutoresizingMaskIntoConstraints = false
        lockerView.translatesAutoresizingMaskIntoConstraints = false
        contentsView.translatesAutoresizingMaskIntoConstraints = false

        coverView.addSubview(contentsView)
        addSubview(coverView)
        addSubview(lockerView)

        setupGetsture()
    }

	private func setConstraints() {
        typealias Const = Design.Standard
        let lockerMarginConstraint = lockerView.rightAnchor.constraint(equalTo: coverView.rightAnchor)
        let lockerWidthConstraint = lockerView.widthAnchor.constraint(equalToConstant: Const.lockerSize.width)
        let lockerHeightConstraint = lockerView.heightAnchor.constraint(equalToConstant: Const.lockerSize.height)
		NSLayoutConstraint.activate([
            coverView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverView.topAnchor.constraint(equalTo: topAnchor),
            coverView.bottomAnchor.constraint(equalTo: bottomAnchor),

            lockerView.centerYAnchor.constraint(equalTo: coverView.centerYAnchor),
            lockerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            contentsView.leadingAnchor.constraint(equalTo: coverView.leadingAnchor),
            contentsView.topAnchor.constraint(equalTo: coverView.topAnchor),
            contentsView.bottomAnchor.constraint(equalTo: coverView.bottomAnchor),
            contentsView.trailingAnchor.constraint(equalTo: coverView.trailingAnchor),

            lockerMarginConstraint,
            lockerWidthConstraint,
            lockerHeightConstraint
		])

        self.lockerMarginConstraint = lockerMarginConstraint
        self.lockerWidthConstraint = lockerWidthConstraint
        self.lockerHeightConstraint = lockerHeightConstraint
	}

    private func setupGetsture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedLockerView))
        lockerView.addGestureRecognizer(tapGesture)
    }

    @objc
    private func didTappedLockerView() {
        didTappedLocker.onNext(())
    }

}

extension DiaryView {
    func setCover(color: PaletteColor) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut
        ) {
            self.coverView.backgroundColor = color.uiColor
            self.lockerView.backgroundColor = color.lockerColor
        }
    }
    
    func setDayolLogoHidden(_ isHidden: Bool) {
        hasLogo = (isHidden == false)
        coverView.setDayolLogoHidden(isHidden)
    }
}
