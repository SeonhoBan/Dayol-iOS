//
//  DiaryPaperViewController.swift
//  Dayol-iOS
//
//  Created by 박종상 on 2021/03/10.
//

import UIKit
import Combine
import RxSwift

enum DiaryPaperEventType {
    case showDatePicker
    case showPaperSelect(paperType: PaperType)
    case showAddSchedule(date: Date, scheduleType: ScheduleModalType)
}

private enum Design {
    enum Margin {
        static let contentProgressSpace: CGFloat = 34
        static let progressSize: CGSize = .init(width: 48, height: 88)
    }
}

class DiaryPaperViewController: DYBaseEditViewController {
    let didReceivedEvent = PublishSubject<DiaryPaperEventType>()
    let index: Int
    let scaleSubject = PassthroughSubject<CGFloat, Error>()
    let viewModel: DiaryPaperViewModel

    private var cancellable = [AnyCancellable]()
    private var paperHeight = NSLayoutConstraint()

    private var scaleVariable: CGFloat {
        let orientation = viewModel.orientation
        let paperSize = PaperOrientationConstant.size(orentantion: orientation)
        if isIPad {
            switch orientation {
            case .portrait:
                return paperScrollView.frame.height / paperSize.height
            case .landscape:
                return paperScrollView.frame.width / paperSize.width
            }
        } else {
            return paperScrollView.frame.width / paperSize.width
        }
    }

    lazy var paper = PaperPresentView(paper: viewModel.paper, count: viewModel.numberOfPapers)
    override var contentsView: DYContentsView {
        get {
            paper.contentsView
        } set {
            paper.contentsView = newValue
        }
    }
    
    private let paperScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()

    private let progressView: DiarySwipeAddPaperView = {
        let progressView = DiarySwipeAddPaperView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.setProgress(0.0)

        return progressView
    }()
    
    init(index: Int, viewModel: DiaryPaperViewModel) {
        self.index = index
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scaleSubject.send(scaleVariable)
    }
    
    private func initView() {
        paper.translatesAutoresizingMaskIntoConstraints = false

        paperScrollView.delegate = self
        paperScrollView.minimumZoomScale = 1.0
        paperScrollView.maximumZoomScale = 3.0
        view.addSubViewPinEdge(paperScrollView)
        paperScrollView.addSubViewPinEdge(paper)
        paperScrollView.isPagingEnabled = true
        view.backgroundColor = UIColor(decimalRed: 246, green: 248, blue: 250)

        progressView.isHidden = true
        view.insertSubview(progressView, aboveSubview: paperScrollView)

        setupConstraint()
        combine()
        setupConstraint()
        paperActionBind()
        viewModelBind()
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            paper.widthAnchor.constraint(equalTo: paperScrollView.widthAnchor),

            progressView.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: Design.Margin.contentProgressSpace),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func showProgressView(show: Bool) {
        progressView.isHidden = !show
    }

    func setProgress(_ progress: CGFloat) {
        progressView.setProgress(progress / 116)
    }
    
    private func combine() {
        let scaleCombine = scaleSubject.sink { error in
            // do Something
        } receiveValue: { [weak self] value in
            guard let self = self else { return }
            self.paper.scaleForFit = value
        }

        cancellable.append(scaleCombine)
    }

    private func viewModelBind() {
        viewModel.paperSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] paper in
                guard let self = self else { return }
                self.paper.set(paper: paper)
            })
            .disposed(by: disposeBag)
    }

}

extension DiaryPaperViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return paper
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        paperScrollView.isPagingEnabled = (scrollView.zoomScale == 1.0)
    }
}

extension DiaryPaperViewController {
    var readyToAdd: Bool {
        return progressView.readyToAdd
    }

    var paperType: PaperType {
        return viewModel.paperType
    }

    func paperActionBind() {
        paper.showPaperSelect
            .observe(on:MainScheduler.instance)
            .subscribe(onNext: { [weak self] paperType in
                self?.didReceivedEvent.onNext(.showPaperSelect(paperType: paperType))
            })
            .disposed(by: disposeBag)

        paper.showAddSchedule
            .observe(on:MainScheduler.instance)
            .subscribe(onNext: { [weak self] date, scheduleType in
                self?.didReceivedEvent.onNext(.showAddSchedule(date: date, scheduleType: scheduleType))
            })
            .disposed(by: disposeBag)
    }
}
