//
//  DiaryEditViewController.swift
//  Dayol-iOS
//
//  Created by 박종상 on 2020/12/29.
//

import UIKit
import RxCocoa
import RxSwift

private enum Design {
    static let paletteHeight: CGFloat = 50
}

private enum Text: String {
    case defaultTitle = "새 다이어리"
    case emptyAlertTitle = "빈타이틀 Title"
    case emptyAlertDesc = "빈타이틀 Desc"
    case backAlertTitle = "뒤로가기 Title"
    case backAlertDesc = "뒤로가기 Desc"
    case confirm = "확인"
    case cancel = "취소"
}

class DiaryEditViewController: DYBaseEditViewController {

    // MARK: - DYEditable Property
    override var contentsView: DYContentsView {
        get {
            return diaryEditCoverView.diaryView.contentsView
        }
        set {
            diaryEditCoverView.diaryView.contentsView = newValue
        }
    }

    // MARK: - Private Properties

    private let leftFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    private let rightFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    private var password: String?
    private var currentCoverColor: PaletteColor = .DYBrown

    let viewModel = DiaryEditViewModel()

    // MARK: - UI Components

    private let titleView = DYNavigationItemCreator.editableTitleView(Text.defaultTitle.rawValue)
    private let leftButton = DYNavigationItemCreator.barButton(type: .back)
    private let rightButton = DYNavigationItemCreator.barButton(type: .done)
    private let diaryEditToggleView: DiaryEditToggleView = {
        let view = DiaryEditToggleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let diaryEditPaletteView: ColorPaletteView = {
        let view = ColorPaletteView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    let diaryEditCoverView: DiaryEditCoverView = {
        let view = DiaryEditCoverView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    // MARK: - Override
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        super.viewDidLoad()
        setupNavigationBar()
        initView()
    }

    override func didTapTextButton() {
        super.didTapTextButton()
        contentsView.currentToolSubject.onNext(nil)
        contentsView.shouldMakeTextField = true
    }

    override func didEndPhotoPick(_ image: UIImage) {
        contentsView.createImageSticker(image: image)
    }

    override func didEndStickerPick(_ image: UIImage) {
        contentsView.createSticker(image: image)
    }
    
    // MARK: - Setup Method
    
    private func initView() {
        view.addSubview(diaryEditToggleView)
        view.addSubview(diaryEditCoverView)
        view.addSubview(diaryEditPaletteView)
        diaryEditPaletteView.colors = viewModel.diaryColors
        setConstraint()
        setupGesture()
        bind()
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            diaryEditToggleView.leftAnchor.constraint(equalTo: view.leftAnchor),
            diaryEditToggleView.topAnchor.constraint(equalTo: view.topAnchor),
            diaryEditToggleView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            diaryEditCoverView.topAnchor.constraint(equalTo: diaryEditToggleView.bottomAnchor),
            diaryEditCoverView.bottomAnchor.constraint(equalTo: diaryEditPaletteView.topAnchor),
            diaryEditCoverView.leftAnchor.constraint(equalTo: view.leftAnchor),
            diaryEditCoverView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            diaryEditPaletteView.leftAnchor.constraint(equalTo: view.leftAnchor),
            diaryEditPaletteView.rightAnchor.constraint(equalTo: view.rightAnchor),
            diaryEditPaletteView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            diaryEditPaletteView.heightAnchor.constraint(equalToConstant: Design.paletteHeight)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        navigationItem.titleView = titleView

        setToolbarItems([UIBarButtonItem(customView: toolBar)], animated: false)
    }
    
    // MARK: - Bind
    
    private func bind() {
        colorBind()
        navigationBind()
        switchBind()
        viewModelBind()
        bindDrawingContentViewBind()
    }
    
    private func switchBind() {
        diaryEditToggleView.changedSwitch
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] show in
                self?.diaryEditCoverView.setDayolLogoHidden(!show)
            })
            .disposed(by: disposeBag)
    }
    
    private func colorBind() {
        diaryEditPaletteView.changedColor
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] paletteColor in
                guard let self = self else { return }
                self.diaryEditCoverView.setCoverColor(color: paletteColor)
                self.currentCoverColor = paletteColor
            })
            .disposed(by: disposeBag)
    }
    
    private func navigationBind() {
        leftButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }

                self.presentAlert(title: Text.backAlertTitle.rawValue,
                                  desc: Text.backAlertDesc.rawValue,
                                  confirm: {
                                    self.dismiss(animated: true, completion: nil)
                                  },
                                  cancel: { })
            }
            .disposed(by: disposeBag)
        
        rightButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.hideKeyboard()
                self.contentsView.resetContentEditStatus()
                self.createDiaryInfo(self.password)
            }
            .disposed(by: disposeBag)

        diaryEditCoverView.didTappedLocker
            .bind { [weak self] in
                guard let self = self else { return }

                self.hideKeyboard()

                self.showPasswordViewController()
            }
            .disposed(by: disposeBag)
        
        titleView.editButton.rx.tap
            .bind { [weak self] in
                self?.titleView.titleTextField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)

        titleView.updatedTitle
            .bind { [weak self] title in
                guard let self = self else { return }
                let titleString = title ?? ""
                self.checkTitleValidation(titleString)
            }
            .disposed(by: disposeBag)
    }

    private func viewModelBind() {
        viewModel.diarySubject
            .observe(on: MainScheduler.instance)
            .bind { [weak self] diary in
                guard let self = self else { return }
                self.titleView.setTitle(diary.title)
                self.diaryEditToggleView.setLogoSwitch(diary.hasLogo)
                self.contentsView.setItems(diary.contents)
                self.contentsView.setDrawData(diary.drawCanvas)

                if let coverColor = PaletteColor.find(hex: diary.colorHex) {
                    self.diaryEditPaletteView.changedColor.onNext(coverColor)
                    self.diaryEditPaletteView.selectColor(coverColor)
                }
            }
        .disposed(by: disposeBag)
    }

    private func checkTitleValidation(_ title: String) {
        if title.isEmpty {
            presentAlert(title: Text.emptyAlertTitle.rawValue,
                                desc: Text.emptyAlertDesc.rawValue,
                                confirm: { [weak self] in
                                    self?.titleView.setTitle(Text.defaultTitle.rawValue)
                                },
                                cancel: nil)
        } else {
            self.titleView.setTitle(title)
        }
    }

    private func presentAlert(title: String, desc: String, confirm: (() -> Void)?, cancel: (() -> Void)?) {
        let alert = DayolAlertController.init(title: title, message: desc)
        alert.addAction(.init(title: Text.confirm.rawValue, style: .default, handler: confirm))

        if let cancelAction = cancel {
            alert.addAction(.init(title: Text.cancel.rawValue, style: .cancel, handler: cancelAction))
        }

        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Password ViewController Subjects

private extension DiaryEditViewController {
    func showPasswordViewController() {
        let passwordViewController = PasswordViewController(inputType: .new, diaryColor: self.currentCoverColor)
        bindDidCreatePassword(passwordViewController)
        present(passwordViewController, animated: true, completion: nil)
    }
    
    func bindDidCreatePassword(_ viewController: PasswordViewController) {
        viewController.didCreatePassword
            .subscribe(onNext: { [weak self] password in
                viewController.dismiss(animated: true, completion: nil)
                self?.diaryEditCoverView.setCoverLock(isLock: true)
                self?.password = password
            }).disposed(by: self.disposeBag)
    }

    func createDiaryInfo(_ password: String?) {
        guard let title = self.titleView.titleLabel.text else { return }
        let diaryView = self.diaryEditCoverView.diaryView

        let isLock = password != nil
        let drawing = contentsView.pkCanvas.drawing
        let hasLogo = diaryView.hasLogo
        let contents = createContents(diaryID: viewModel.diaryID)
        var drawCanvasData = Data()

        let encoder = JSONEncoder()
        if let drawingData = try? encoder.encode(drawing) {
            drawCanvasData = drawingData
        }

        viewModel.createDiaryInfo(
            isLock: isLock,
            title: title,
            colorHex: currentCoverColor.hexString,
            drawCanvas: drawCanvasData,
            hasLogo: hasLogo,
            thumbnail: diaryEditCoverView.asThumbnail?.pngData() ?? Data(),
            contents: contents
        )

        self.dismiss(animated: true, completion: nil)
    }

    func createContents(diaryID: String) -> [DecorationItem] {
        return contentsView.getItems(parentID: diaryID)
    }
}

// MARK: - Keyboard Control

private extension DiaryEditViewController {

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc
    func hideKeyboard() {
        // titleView 가 네비게이션 타이틀 바에 붙어있어서 직접 호출해줘야한다.
        titleView.endEditing(true)
        view.endEditing(true)
    }

}
