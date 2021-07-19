//
//  DYContentsView.swift
//  Dayol-iOS
//
//  Created by 박종상 on 2021/03/18.
//

import UIKit
import PencilKit
import RxSwift

class DYContentsView: UIView, Undoable {
    private let disposeBag = DisposeBag()
    // TODO: - 모달 수정하면서 contents용 canvas 추가
    let pkCanvas = PKCanvasView()
    let currentToolSubject = BehaviorSubject<DYCanvasTool?>(value: nil)
    var currentEditContent: DYStickerView? = nil {
        didSet {
            oldValue?.showEditingHandlers = false
            currentEditContent?.showEditingHandlers = true
        }
    }
    var shouldMakeTextField = false
    var didEndCreateTextField: (() -> Void)?

    init() {
        super.init(frame: .zero)
        initView()
        bindEvent()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if shouldMakeTextField {
            shouldMakeTextField = false
            createTextField(targetPoint: point)
            didEndCreateTextField?()
        }
        return super.point(inside: point, with: event)
    }

    private func initView() {
        pkCanvas.backgroundColor = .clear
        addSubViewPinEdge(pkCanvas)
        addGesture()

        if isIPad == false {
            // 아이패드가 아니면 손가락 인풋 허용
            if #available(iOS 14.0, *) {
                pkCanvas.drawingPolicy = .anyInput
            } else {
                pkCanvas.allowsFingerDrawing = true
            }
        } else {
            // TODO: 현재는 임시 로직, 아이패드용 펜 설정 버튼과 연동해야함
            if #available(iOS 14.0, *) {
                pkCanvas.drawingPolicy = .anyInput
            } else {
                pkCanvas.allowsFingerDrawing = true
            }
        }
    }

    private func bindEvent() {
        currentToolSubject.bind { [weak self] tool in
            guard let pkTool = tool?.pkTool else {
                self?.pkCanvas.isUserInteractionEnabled = false
                return
            }
            self?.pkCanvas.isUserInteractionEnabled = true
            self?.pkCanvas.tool = pkTool
        }
        .disposed(by: disposeBag)
    }

    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedAnyWhere(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc
    private func didTappedAnyWhere(_ sender: Any) {
        currentEditContent?.showEditingHandlers = false
    }

    func resetContentEditStatus() {
        currentEditContent?.showEditingHandlers = false
    }
}

// MARK: - Init Items

extension DYContentsView {

    // 최초 생성
    func createTextField(targetPoint: CGPoint) {
        let id = DYTestData.shared.textFieldIdToCreate
        DYTestData.shared.increaseTextFieldID()

        let viewModel = DYFlexibleTextFieldViewModel(id: id)
        let textField = DYFlexibleTextField(viewModel: viewModel)
        textField.center = targetPoint

        addSubviewWithUndoManager(textField)
    }

    func createImageSticker(image: UIImage, currentPage: Int = 0) {
        // TODO: 사용자 사진 ID 룰 정의
        let id = "test user image id"
        setStreachableView(id: id, image: image, currentPage: currentPage, isUserImage: true)
    }

    func createSticker(image: UIImage, currentPage: Int = 0) {
        // TODO: 스티커 ID 룰 정의
        let id = "test sticker image id"
        setStreachableView(id: id, image: image, currentPage: currentPage, isUserImage: false)
    }

    private func setStreachableView(id: String, image: UIImage, currentPage: Int, isUserImage: Bool) {
        // TODO: - 속지에서 superview의 스케일때문에 센터가 잘 안맞는 것 같은데 종상이형이 한번 손봐주면 좋을 것 같습니다.
        // TODO: - id 연동 작업 필요
        let calcedCenter = CGPoint(x: center.x, y: center.y * CGFloat(currentPage + 1))
        let imageView = UIImageView(image: image)
        let imageRatio = image.size.height / image.size.width
        let defaultImageWith: CGFloat = DYStickerBaseView.defaultImageWidth
        let calcedImageHeight: CGFloat = imageRatio * DYStickerBaseView.defaultImageWidth
        imageView.frame.size = CGSize(width: defaultImageWith, height: calcedImageHeight)

        let stickerView: DYStickerBaseView
        if isUserImage {
            stickerView = DYImageSizeStretchableView(contentView: imageView)
        } else {
            stickerView = DYStickerSizeStretchableView(contentView: imageView)
        }

        stickerView.enableClose = true
        stickerView.enableRotate = true
        stickerView.enableHStretch = true
        stickerView.enableWStretch = true
        stickerView.showEditingHandlers = false
        stickerView.center = calcedCenter
        stickerView.delegate = self
        currentEditContent = stickerView
        addSubviewWithUndoManager(stickerView)
    }
}

// MARK: - Retrieve Items

extension DYContentsView {
    func setDrawData(_ drawData: Data) {
        let decoder = JSONDecoder()
        if let drawing = try? decoder.decode(PKDrawing.self, from: drawData) {
            pkCanvas.drawing = drawing
        }
    }

    func setItems(_ items: [DecorationItem]) {
        items.forEach { item in
            if let textItem = item as? DecorationTextFieldItem {
                let viewModel = DYFlexibleTextFieldViewModel(id: item.id)
                let textField = DYFlexibleTextField(viewModel: viewModel)
                textField.viewModel.set(textItem)
                addSubview(textField)
            } else if let imageItem = item as? DecorationImageItem {
                let stretchableView = DYImageSizeStretchableView(model: imageItem)
                addSubview(stretchableView)
            } else if let stickerItem = item as? DecorationStickerItem {
                let stretchableView = DYStickerSizeStretchableView(model: stickerItem)
                addSubview(stretchableView)
            }
        }

    }
}

// MARK: - Get Items

extension DYContentsView {
    // TODO: getItems, drawd data 동작을 나누지 않고 한번에 처리하도록 수정
    func getItems(parentID: String) -> [DecorationItem] {
        let items: [DecorationItem] = subviews.compactMap { subview in
            if let textField = subview as? DYFlexibleTextField {
                return textField.toItem(parentId: parentID)
            }

            // TODO: - ContentView ViewModel 정의하여 뷰모델에서 Item을 받아오도록 수정
            if let imageStretchView = subview as? DYImageSizeStretchableView {
                // TODO: - 유저 이미지 스티커 ID 룰 정의
                return imageStretchView.toItem(id: "", parentId: parentID)
            }

            if let stickerStrechView = subview as? DYStickerSizeStretchableView {
                // TODO: - 스티커 ID 룰 정의
                return stickerStrechView.toItem(id: "", parentId: parentID)
            }

            return nil
        }
        return items
    }
}

// MARK: - Sticker Delegate

extension DYContentsView: DYStickerViewDelegate {
    func stickerView(_ stickerView: DYStickerView, didTapSticker: Bool) {
        currentEditContent = stickerView
        stickerView.showEditingHandlers = true
    }
}
