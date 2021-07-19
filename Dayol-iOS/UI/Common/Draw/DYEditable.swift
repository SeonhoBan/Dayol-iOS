//
//  DYEditable.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/04/26.
//

import UIKit
import RxCocoa
import RxSwift

private enum Design {
    static let defaultTextFieldSize = CGSize(width: 20, height: 30)
    static let penSettingModalHeight: CGFloat = 146.0
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
    static var penTitle: String {
        return "edit_pen_title".localized
    }
}

protocol DYEditable: NSObject {
    var disposeBag: DisposeBag { get }

    var contentsView: DYContentsView { get set }
    var toolBar: DYNavigationDrawingToolbar { get }
    var currentTool: DYNavigationDrawingToolbar.ToolType? { get set }
    var pkTools: DYPKTools { get set }

    // ImagePicker는 델리게이트 처리 떄문에 DYEditBaseViewController에서 함수 구현
    func showImagePicker()

    // 씬 마다 동작이 달라서 override 후 추가 구현 필요
    func didTapTextButton()
    func didEndPhotoPick(_ image: UIImage)
    func didEndStickerPick(_ image: UIImage)
}

extension DYEditable where Self: UIViewController {

    func bindToolBarEvent() {
        undoRedoBind()
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
        // TODO: - 지우개 연동
        let contentView = EraseSettingView(isObjectErase: false)
        modalVC.dismissCompeletion = {}
        modalVC.contentView = contentView
        self.presentCustomModal(modalVC)
    }

    private func presentPencilModal() {
        let configuration = DYModalConfiguration(dimStyle: .clear, modalStyle: .custom(containerHeight: Design.penSettingModalHeight))
        let modalVC = DYModalViewController(configure: configuration,
                                            title: Text.penTitle,
                                            hasDownButton: true)
        let contentView = PencilSettingView(pkTools: pkTools)
        contentView.currentToolsSubject
            .subscribe(onNext: { [weak self] tools in
                self?.pkTools = tools
            })
            .disposed(by: disposeBag)
        contentView.showColorPicker = { [weak self] color in
            guard let self = self else { return }
            modalVC.dismiss(animated: true) {
                self.presentColorPickerModal(currentColor: color)
            }
        }
        contentView.showDetailPiker = { detailViewInfo in
            modalVC.showPopover(
                contents: detailViewInfo.contents,
                sender: detailViewInfo.sender,
                preferredSize: detailViewInfo.preferredSize
            )
        }

        modalVC.contentView = contentView
        presentCustomModal(modalVC)
    }

    private func presentColorPickerModal(currentColor: UIColor) {
        let configuration = DYModalConfiguration(dimStyle: .clear, modalStyle: .custom(containerHeight: 441.0))
        let modalVC = DYModalViewController(configure: configuration,
                                            title: Text.penTitle,
                                            hasDownButton: true)

        let contentView = ColorSettingView()
        contentView.set(color: currentColor)
        contentView.colorSubject
            .subscribe(onNext: { [weak self] color in
                self?.pkTools.updateSelectedTool(color: color)
            })
            .disposed(by: disposeBag)

        modalVC.contentView = contentView
        modalVC.dismissCompeletion = { [weak self] in
            self?.presentPencilModal()
        }
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

        contentsView.shouldMakeTextField = false
    }

}

// MARK: - Tool Bar Event

extension DYEditable where Self: UIViewController {

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

extension DYEditable where Self: UIViewController {

    // MARK: - Pencil

    func didTapPencilButton() {
        contentsView.currentToolSubject.onNext(pkTools.selectedTool)
        contentsView.shouldMakeTextField = false
    }

}
