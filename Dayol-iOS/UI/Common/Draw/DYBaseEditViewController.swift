//
//  DYBaseEditViewController.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/06/23.
//

import UIKit
import PhotosUI
import RxSwift

private enum Design {
    static let toastHeight: CGFloat = 40
    static let toastBottomMargin: CGFloat = 40
}

private enum Text {
    static var textFieldToast: String {
        "원하는 위치를 탭하면 텍스트박스가 생성됩니다.".localized
    }
}

class DYBaseEditViewController: UIViewController, DYEditable {
    let disposeBag = DisposeBag()

    let toolBar = DYNavigationItemCreator.drawingFunctionToolbar()

    var contentsView = DYContentsView()
    // TODO: - currentToolbarType? 등으로 이름 변경
    var currentTool: DYNavigationDrawingToolbar.ToolType?
    var pkTools: DYPKTools = DYPKTools() {
        didSet { contentsView.currentToolSubject.onNext(pkTools.selectedTool) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindToolBarEvent()
    }

    func showTextFieldToast() {
        // TODO: - 검수 끝나면 한번만 노출하는 스펙 추가
        var configure = DYToastConfigure.deafault
        configure.height = Design.toastHeight

        view.showToast(
            text: Text.textFieldToast,
            bottomMargin: Design.toastBottomMargin,
            configure: configure
        )
    }

    /// 오버라이드하여 사용처에서 좌표 제어
    func didTapTextButton() {
        showTextFieldToast()
    }

    func bindDrawingContentViewBind() {
        contentsView.didEndCreateTextField = { [weak self] in
            self?.currentTool = nil
            self?.toolBar.textButton.isSelected = false
        }
    }

    func didEndPhotoPick(_ image: UIImage) {}
    func didEndStickerPick(_ image: UIImage) {}
}

// MARK: - Drawbale Function

extension DYBaseEditViewController {

    func showImagePicker() {
        contentsView.shouldMakeTextField = false

        if #available(iOS 14.0, *) {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .any(of: [.images])

            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true, completion: nil)

        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary

            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                present(picker, animated: true)
            }
        }
    }

}

// MARK: - Photo Delegate

extension DYBaseEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            didEndPhotoPick(image)
        }
        dismiss(animated: true, completion: nil)
    }

    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                guard let self = self, let image = image as? UIImage else { return }

                DispatchQueue.main.async {
                    self.didEndPhotoPick(image)
                }
            }
        }
    }
}

