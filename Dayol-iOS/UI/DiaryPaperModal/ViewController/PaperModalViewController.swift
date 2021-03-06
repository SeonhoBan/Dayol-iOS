//
//  PaperModalViewController.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/01/12.
//

import UIKit
import RxSwift
import RxCocoa

private enum Design {

}

private enum Text {
    static var selectMonth: String { "Monthly 메모지 선택" }
    static var selectWeek: String { "Weekly 메모지 선택" }
}

protocol PaperModalViewDelegate: NSObject {
    func didTappedItem(_ index: Paper)
    func didTappedAddItem()
    func didTappedAddDone(paperType: PaperType, orientation: Paper.PaperOrientation)
    func didSelectedDate(didSelected date: Date?)
    func didTappedMonthlyAdd()
}

class PaperModalViewController: DYModalViewController {

    enum PaperToolType {
        case add
        case list
        case paperType(type: PaperType)
        case date
        case shedule(date: Date, scheduleType: ScheduleModalType)
    }

    private let disposeBag = DisposeBag()
    private let diaryId: String
    // MARK: - UI Property

    public weak var delegate: PaperModalViewDelegate?

    var toolType: PaperToolType

    init(diaryId: String, toolType: PaperToolType, configure: DYModalConfiguration) {
        self.diaryId = diaryId
        self.toolType = toolType
        super.init(configure: configure)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        viewNeedsLayout(size: size)
    }

    // MARK: - Setup

    private func setupViews() {
        switch toolType {
        case .add:
            setupPaperAddView()
        case .list:
            setupPaperListtView()
        case let .paperType(type: type):
            setupMonthListView(paperType: type)
        case .date:
            setupDatePickerView()
        case .shedule(let date, let scheduleType):
            setupScheduleView(date: date, scheduleType: scheduleType)
        }
    }

    private func setupPaperAddView() {
        let titleView = AddPaperHeaderView()
        let contentView = AddPaperContentView()
        self.titleView = titleView
        self.contentView = contentView

        bindAddPaperEvent()
    }

    private func setupPaperListtView() {
        let titleView = PaperListHeaderView()
        let contentView = PaperListContentView(diaryId: diaryId)
        self.titleView = titleView
        self.contentView = contentView

        bindPaperListEvent()
    }

    private func setupMonthListView(paperType: PaperType) {
        let titleView = PaperSelectHeaderView()
        let contentView = PaperSelectCollectionView(diaryId: diaryId, paperBeDisplayed: paperType)
        self.titleView = titleView
        self.contentView = contentView

        setupTitleLabel(Text.selectMonth)
        setupRightDownButton()

        bindMonthListEvent()
    }

    private func setupDatePickerView() {
        let titleView = DatePickerHeaderView()
        let contentView = DatePickerView()
        self.titleView = titleView
        self.contentView = contentView

        bindDatePickerEvent()
    }

    private func setupScheduleView(date: Date, scheduleType: ScheduleModalType) {
        let titleView = ScheduleModalHeaderView()
        let contentView = ScheduleModalContentView(date: date, scheduleType: scheduleType)
        self.titleView = titleView
        self.contentView = contentView

        bindSchduleEvent()
    }

    // MARK: - Layout Update

    private func viewNeedsLayout(size: CGSize) {
        switch toolType {
        case .add:
            paperAddViewNeedsLayout(size: size)
        case .list:
            paperListViewNeedsLayout()
        case let .paperType(type: _):
            monthlyPaperListViewNeedsLayout()
        case .date:
            datePickerViewNeedsLayout()
        case .shedule:
            scheduleViewNeedsLayout()
        }
    }

    private func paperAddViewNeedsLayout(size: CGSize) {
        guard let paperAddContentView = contentView as? AddPaperContentView else { return }
        paperAddContentView.layoutCollectionView(width: size.width)
    }

    private func paperListViewNeedsLayout() {
        guard let paperListContentView = contentView as? PaperListContentView else { return }
        paperListContentView.layoutCollectionView()
    }

    private func monthlyPaperListViewNeedsLayout() {
        guard let monthlyPaperListContentView = contentView as? PaperSelectCollectionView else { return }
        monthlyPaperListContentView.layoutCollectionView()
    }

    private func datePickerViewNeedsLayout() {
        guard let datePickerContentView = contentView as? DatePickerView else { return }
        datePickerContentView.setNeedsLayout()
    }

    private func scheduleViewNeedsLayout() {
        guard let schduleContentView = contentView as? ScheduleModalContentView else { return }
        schduleContentView.setNeedsLayout()
    }
}

// MARK: - Bind

private extension PaperModalViewController {

    func bindEvent() {
        switch toolType {
        case .add:
            bindAddPaperEvent()
        case .list:
            bindPaperListEvent()
        case let .paperType(type: _):
            bindMonthListEvent()
        case .date:
            bindDatePickerEvent()
        case .shedule:
            bindSchduleEvent()
        }
    }

    func bindAddPaperEvent() {
        guard let addPaperHeaderView = titleView as? AddPaperHeaderView,
              let addPaperContentView = contentView as? AddPaperContentView
        else {
            return
        }

        addPaperHeaderView.barLeftButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        addPaperHeaderView.barRightButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: {
                    guard let paper = addPaperContentView.viewModel.selectedPaper else { return }
                    self.delegate?.didTappedAddDone(paperType: paper.paperType, orientation: paper.orientation)
                })
            }
            .disposed(by: disposeBag)
    }

    func bindPaperListEvent() {
        guard let paperListHeaderView = titleView as? PaperListHeaderView,
              let paperListContentView = contentView as? PaperListContentView
        else {
            return
        }

        paperListHeaderView.closeButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        paperListContentView.didSelectAddCell
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.delegate?.didTappedAddItem()
                }
            })
            .disposed(by: disposeBag)

        paperListContentView.didSelectItem
            .subscribe(onNext: { [weak self] paper in
                self?.dismiss(animated: true) {
                    self?.delegate?.didTappedItem(paper)
                }
            })
            .disposed(by: disposeBag)
    }

    func bindDatePickerEvent() {
        guard let datePickerHeaderView = titleView as? DatePickerHeaderView,
              let datePickerContentView = contentView as? DatePickerView
        else {
            return
        }

        Observable.combineLatest(datePickerContentView.didSelectYear, datePickerContentView.didSelectMonth, datePickerHeaderView.didTappedConfirmButton)
            .filter { $0.0?.isEmpty == false && $0.1?.isEmpty == false }
            .subscribe(onNext: { [weak self] year, month, _ -> Void in
                guard let self = self else { return }
                let dateString = "\(year ?? "") \(month ?? "")"
                self.dismiss(animated: true) {
                    let date = DateType.yearMonth.formatter.date(from: dateString)
                    self.delegate?.didSelectedDate(didSelected: date)
                }
            })
            .disposed(by: disposeBag)
    }

    func bindMonthListEvent() {
        guard let monthlyPagerListContentView = contentView as? PaperSelectCollectionView else { return }

        monthlyPagerListContentView.didSelect
            .subscribe(onNext: { [weak self] selectEvent in
                guard let self = self else { return }

                switch selectEvent {
                case .item(paper: let paper):
                    self.dismiss(animated: true) {
                        self.delegate?.didTappedItem(paper)
                    }
                case .add:
                    self.dismiss(animated: true) {
                        self.delegate?.didTappedMonthlyAdd()
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    func bindSchduleEvent() {
        guard let scheduleContentView = contentView as? ScheduleModalContentView,
              let scheduleHeaderView = titleView as? ScheduleModalHeaderView
        else { return }

        scheduleHeaderView.didTappedButton
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .done: self.dismiss(animated: true)
                case .cancel: self.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}
