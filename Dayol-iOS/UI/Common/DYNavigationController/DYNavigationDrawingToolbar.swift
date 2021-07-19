//
//  DYNavigationDrawingToolbar.swift
//  Dayol-iOS
//
//  Created by 박종상 on 2021/01/01.
//

import UIKit
import RxSwift
import RxCocoa

private enum Design {
    static let buttonSize: CGSize = CGSize(width: 36, height: 36)
    
    static let eraserImage = UIImage(named: "eraserButton")
    static let pencilImage = UIImage(named: "pencilButton")
    static let photoImage = UIImage(named: "photoButton")
    static let redoImage = UIImage(named: "redoButton")
    static let snareImage = UIImage(named: "snareButton")
    static let stickerImage = UIImage(named: "stickerButton")
    static let textImage = UIImage(named: "textButton")
    static let undoImage = UIImage(named: "undoButton")
    
    static let selectedImage = UIImage(named: "selectedButton")
    
    static let containerSpacing: CGFloat = 14
    static let buttonSpacing: CGFloat = 6
}

class DYNavigationDrawingToolbar: UIView {

    enum ToolType {
        case pencil
        case photo
        case redo
        case sticker
        case text
        case undo
    }

    private let disposeBag = DisposeBag()
    let toolBarEvent: BehaviorSubject<ToolType> = BehaviorSubject(value: .pencil)
    
    private let containerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Design.containerSpacing
        
        return stackView
    }()
    
    private let leftView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Design.buttonSpacing
        
        return stackView
    }()
    
    private let rightView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        
        return stackView
    }()

    let pencilButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: Design.buttonSize.width, height: Design.buttonSize.height))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Design.pencilImage, for: .normal)
        button.setBackgroundImage(Design.selectedImage, for: .selected)
        
        return button
    }()
    
    let photoButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: Design.buttonSize.width, height: Design.buttonSize.height))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Design.photoImage, for: .normal)
        button.setBackgroundImage(Design.selectedImage, for: .selected)
        
        return button
    }()
    
    let redoButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: Design.buttonSize.width, height: Design.buttonSize.height))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Design.redoImage, for: .normal)
        button.setBackgroundImage(Design.selectedImage, for: .selected)
        
        return button
    }()
    
    let stickerButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: Design.buttonSize.width, height: Design.buttonSize.height))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Design.stickerImage, for: .normal)
        button.setBackgroundImage(Design.selectedImage, for: .selected)
        
        return button
    }()
    
    let textButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: Design.buttonSize.width, height: Design.buttonSize.height))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Design.textImage, for: .normal)
        button.setBackgroundImage(Design.selectedImage, for: .selected)
        
        return button
    }()
    
    let undoButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: Design.buttonSize.width, height: Design.buttonSize.height))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Design.undoImage, for: .normal)
        button.setBackgroundImage(Design.selectedImage, for: .selected)
        
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        initView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        let space = UIView()
        leftView.addArrangedSubview(undoButton)
        leftView.addArrangedSubview(redoButton)

        rightView.addArrangedSubview(pencilButton)
        rightView.addArrangedSubview(textButton)
        rightView.addArrangedSubview(stickerButton)
        rightView.addArrangedSubview(photoButton)
        
        containerView.addArrangedSubview(leftView)
        containerView.addArrangedSubview(space)
        containerView.addArrangedSubview(rightView)
        
        addSubview(containerView)
        
        setConstraint()
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([            
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leftAnchor.constraint(equalTo: leftAnchor),
            containerView.rightAnchor.constraint(equalTo: rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

//MARK: - Bind

private extension DYNavigationDrawingToolbar {
    func bind() {
        bindPhotoButton()
        bindPencilButton()
        bindTextButton()
        bindStickerButton()
    }
    
    func bindPencilButton() {
        pencilButton.rx.tap
            .bind { [weak self] in
                self?.clearButtons()
                self?.toolBarEvent.onNext(.pencil)
                self?.pencilButton.isSelected = true
            }
            .disposed(by: disposeBag)
    }
    
    func bindPhotoButton() {
        photoButton.rx.tap
            .bind { [weak self] in
                self?.clearButtons()
                self?.toolBarEvent.onNext(.photo)
                self?.photoButton.isSelected = true
            }
            .disposed(by: disposeBag)
    }
    
    func bindStickerButton() {
        stickerButton.rx.tap
            .bind { [weak self] in
                self?.clearButtons()
                self?.toolBarEvent.onNext(.sticker)
                self?.stickerButton.isSelected = true
            }
            .disposed(by: disposeBag)
    }
    
    func bindTextButton() {
        textButton.rx.tap
            .bind { [weak self] in
                self?.clearButtons()
                self?.toolBarEvent.onNext(.text)
                self?.textButton.isSelected = true
            }
            .disposed(by: disposeBag)
    }
    
    private func clearButtons() {
        rightView.arrangedSubviews.forEach { ($0 as? UIButton)?.isSelected = false }
    }
}
