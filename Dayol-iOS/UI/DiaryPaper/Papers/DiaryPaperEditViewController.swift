//
//  DiaryPaperEditViewController.swift
//  Dayol-iOS
//
//  Created by 박종상 on 2021/03/25.
//

import UIKit
import RxSwift

class DiaryPaperEditViewController: DiaryPaperViewController {

    private enum Text: String {
        case editTitle = "edit_memo_title"
        
        var stringValue: String {
            return self.rawValue.localized
        }
    }

    // MARK: - UI Components
    
    private let leftButton = DYNavigationItemCreator.barButton(type: .back)
    private let leftFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    private let rightFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    private let titleView = DYNavigationItemCreator.titleView(Text.editTitle.stringValue)

    // MARK: - Init
    
    init(viewModel: DiaryPaperViewModel) {
        super.init(index: 0, viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        contentsView.isUserInteractionEnabled = true
        bindDrawingContentViewBind()
    }

    override func didTapTextButton() {
        super.didTapTextButton()
        contentsView.currentToolSubject.onNext(nil)
        contentsView.shouldMakeTextField = true

        /*
         TODO: - contentsView에 속지 정보를 줘야함 종상형 헬프
         1. 속지 정보 (fitMode를 해줘야하는 속지인지, isFitMode?)
         2. fit 되야하는 프레임 정보

         1, 2 를 얻을 수 있는 인터페이스가 있으면 편할 것 같음 추후에 구현 필요
         */
    }

    override func didEndPhotoPick(_ image: UIImage) {
        contentsView.createImageSticker(image: image)
    }

    override func didEndStickerPick(_ image: UIImage) {
        contentsView.createSticker(image: image)
    }
    
    // MARK: - Setup
    
    private func setupNavigationController() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        navigationItem.titleView = titleView
        
        setToolbarItems([UIBarButtonItem(customView: toolBar)], animated: false)
        
        leftButton.addTarget(self, action: #selector(dismissWithNoAnimation), for: .touchUpInside)
    }
    
    @objc
    private func dismissWithNoAnimation() {
        // 데이터 저장
        let drawData = contentsView.pkCanvas.drawing
        let items: [DecorationItem] = contentsView.getItems(parentID: viewModel.paperId)
        let encoder = JSONEncoder()

        if let drawingData = try? encoder.encode(drawData) {
            viewModel.update(items: items, drawing: drawingData)
        }

        self.dismiss(animated: false, completion: nil)
    }

}
