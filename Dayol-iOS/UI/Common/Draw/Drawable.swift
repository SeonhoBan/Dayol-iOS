//
//  Drawable.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/04/26.
//

import UIKit
import RxCocoa
import RxSwift

private enum Design {
    static let defaultTextFieldSize = CGSize(width: 20, height: 30)
    static let penSettingModalHeight: CGFloat = 554.0
    static let textColorSettingModalHeight: CGFloat = 441.0
}

private enum Text {
    static var textStyleTitle: String {
        return "text_style_title".localized
    }
    static var textColorStyleTitle: String {
        return "text_style_color".localized
    }
    static var eraseTitle: String {
        return "edit_eraser_title".localized
    }
    static var lassoTitle: String {
        return "edit_lasso_title".localized
    }
    static var penTitle: String {
        return "edit_pen_title".localized
    }
}

protocol Drawable: DYViewController {
    var disposeBag: DisposeBag { get }

    var drawingContentView: DrawingContentView { get set }
    var toolBar: DYNavigationDrawingToolbar { get }
    var currentTool: DYNavigationDrawingToolbar.ToolType? { get set }
    var currentEraseTool: DYEraseTool { get set }
    var currentPencilTool: DYPencilTool { get set }

    // ImagePicker는 델리게이트 처리 떄문에 DrawableViewController에서 함수 구현
    func showImagePicker()

    // 씬 마다 동작이 달라서 override 후 추가 구현 필요
    func didTapTextButton()
    func didEndPhotoPick(_ image: UIImage)
    func didEndStickerPick(_ image: UIImage)
}

extension Drawable where Self: DYViewController {

    func bindToolBarEvent() {
        undoRedoBind()
        lassoToolBind()
        eraseBind()
        penBind()
        textFieldBind()
        photoBind()
        stickerBind()
    }

    private func showEraseModal() {
        let modalHeight = DYModalViewController.headerAreaHeight + EraseSettingView.contentHeight
        let configuration = DYModalConfiguration(dimStyle: .black, modalStyle: .custom(containerHeight: modalHeight))
        let modalVC = DYModalViewController(configure: configuration,
                                            title: Text.eraseTitle,
                                            hasDownButton: true)
        let isObjectErase = currentEraseTool.isObjectErase
        let contentView = EraseSettingView(isObjectErase: isObjectErase)
        modalVC.dismissCompeletion = { [weak self] in
            let newIsObjectErase = contentView.isObjectErase
            self?.didEndEraseSetting(isObjectErase: newIsObjectErase)
        }
        modalVC.contentView = contentView
        self.presentCustomModal(modalVC)
    }

    private func presentPencilModal() {
        let configuration = DYModalConfiguration(dimStyle: .black, modalStyle: .custom(containerHeight: Design.penSettingModalHeight))
        let modalVC = DYModalViewController(configure: configuration,
                                            title: Text.penTitle,
                                            hasDownButton: true)
        let currentColor = currentPencilTool.color
        let isHighlighter = currentPencilTool.isHighlighter
        let currnetPencilType: PencilTypeSettingView.PencilType = isHighlighter ? .highlighter : .pen
        let contentView = PencilSettingView(currentColor: currentColor, pencilType: currnetPencilType)
        modalVC.dismissCompeletion = { [weak self] in
            let newColor = contentView.currentPencilInfo.color
            let newIsHighlighter = contentView.currentPencilInfo.pencilType == .highlighter ? true : false
            self?.didEndPencilSetting(color: newColor, isHighlighter: newIsHighlighter)
        }
        modalVC.contentView = contentView
        presentCustomModal(modalVC)
    }

    private func presentStickerModal() {
        let stickerModal = StickerModalViewContoller()
        presentCustomModal(stickerModal)

        stickerModal.didTappedSticker
            .subscribe(onNext: { stickerImage in
                guard let stickerImage = stickerImage else { return }
                self.didEndStickerPick(stickerImage)
            })
            .disposed(by: disposeBag)

        drawingContentView.shouldMakeTextField = false
    }

}

// MARK: - Tool Bar Event

extension Drawable where Self: DYViewController {

    private func undoRedoBind() {
        toolBar.undoButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                if self.undoManager?.canUndo == true {
                    self.undoManager?.undo()
                }
                self.currentTool = .undo
            }
            .disposed(by: disposeBag)

        toolBar.redoButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                if self.undoManager?.canRedo == true {
                    self.undoManager?.redo()
                }
                self.currentTool = .redo
            }
            .disposed(by: disposeBag)
    }

    private func eraseBind() {
        toolBar.eraserButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                guard self.currentTool == .eraser else {
                    self.currentTool = .eraser
                    self.didTapEraseButton()
                    return
                }
                self.showEraseModal()
            }
            .disposed(by: disposeBag)
    }

    private func lassoToolBind() {
        toolBar.snareButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                guard self.currentTool == .snare else {
                    self.currentTool = .snare
                    self.didTapSnareButton()
                    return
                }
                let configuration = DYModalConfiguration(dimStyle: .black, modalStyle: .small)
                let modalVC = DYModalViewController(configure: configuration,
                                                    title: Text.lassoTitle,
                                                    hasDownButton: true)
                modalVC.contentView = LassoInfoView()
                self.presentCustomModal(modalVC)
            }
            .disposed(by: disposeBag)
    }

    private func penBind() {
        toolBar.pencilButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                guard self.currentTool == .pencil else {
                    self.currentTool = .pencil
                    self.didTapPencilButton()
                    return
                }
                self.presentPencilModal()
            }
            .disposed(by: disposeBag)
    }

    private func textFieldBind() {
        toolBar.textButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                guard self.currentTool != .text else { return }
                self.currentTool = .text
                self.didTapTextButton()
                return
            }
            .disposed(by: disposeBag)
    }

    private func photoBind() {
        toolBar.photoButton.rx.tap
            .bind { [weak self] in
                self?.currentTool = .photo
                self?.showImagePicker()
            }
            .disposed(by: disposeBag)
    }

    private func stickerBind() {
        toolBar.stickerButton.rx.tap
            .bind { [weak self] in
                self?.currentTool = .sticker
                self?.presentStickerModal()
            }
            .disposed(by: disposeBag)
    }

}

extension Drawable where Self: DYViewController {

    // MARK: - Pencil

    func didTapPencilButton() {
        let pencilColor = currentPencilTool.color
        let isHighlighter = currentPencilTool.isHighlighter
        let pencilTool = DYPencilTool(color: pencilColor, isHighlighter: isHighlighter)
        drawingContentView.currentToolSubject.onNext(pencilTool)
        drawingContentView.shouldMakeTextField = false
    }

    func didEndPencilSetting(color: UIColor, isHighlighter: Bool) {
        let pencilTool = DYPencilTool(color: color, isHighlighter: isHighlighter)
        currentPencilTool = pencilTool
        drawingContentView.currentToolSubject.onNext(pencilTool)
    }


    // MARK: - Erase

    func didTapEraseButton() {
        let isObjectErase = currentEraseTool.isObjectErase
        let eraseTool = DYEraseTool(isObjectErase: isObjectErase)
        drawingContentView.currentToolSubject.onNext(eraseTool)
        drawingContentView.shouldMakeTextField = false
    }

    func didEndEraseSetting(isObjectErase: Bool) {
        let eraseTool = DYEraseTool(isObjectErase: isObjectErase)
        currentEraseTool = eraseTool
        drawingContentView.currentToolSubject.onNext(eraseTool)
    }

    // MARK: - Snare(Lasso)

    func didTapSnareButton() {
        let lassoTool = DYLassoTool()
        drawingContentView.currentToolSubject.onNext(lassoTool)
        drawingContentView.shouldMakeTextField = false
    }
}
