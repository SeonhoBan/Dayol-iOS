//
//  MonthlyCalendarView.swift
//  Dayol-iOS
//
//  Created by 박종상 on 2021/01/25.
//

import UIKit
import RxSwift
import RxCocoa

class MonthlyCalendarView: BasePaper {
    private var dateModel: MonthlyCalendarDataModel?
    private var containerViewLeft = NSLayoutConstraint()
    private var containerViewRight = NSLayoutConstraint()

    var disposeBag = DisposeBag()
    
    let showSelectPaper = PublishSubject<Void>()
    let showAddSchedule = PublishSubject<Date>()

    private let headerView: MonthlyCalendarHeaderView = {
        let header = MonthlyCalendarHeaderView(month: .january)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.isUserInteractionEnabled = true

        return header
    }()
    
    private let collectionView: MonthlyCalendarCollectionView = {
        let collectionView = MonthlyCalendarCollectionView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    override func configure(viewModel: PaperViewModel, orientation: Paper.PaperOrientation) {
        super.configure(viewModel: viewModel, orientation: orientation)

        collectionView.orientation = orientation

        contentView.addSubview(headerView)
        contentView.addSubview(collectionView)
        setupConstraints()
        
        bind()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func bind() {
        guard let viewModel = self.viewModel as? MonthlyCalendarViewModel else { return }
        viewModel.dateModel()
            .subscribe(onNext: { [weak self] dateModel in
                guard let self = self else { return }
                self.dateModel = dateModel
                let _ = dateModel.month
                let days = dateModel.days
                self.collectionView.firstDatesOfSunday = viewModel.datesOfSunday
                self.collectionView.days = days
                self.headerView.month = dateModel.month
            })
            .disposed(by: disposeBag)

        collectionView.longTappedIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                let day = self.dateModel?.days[index].dayNumber ?? 0
                let month = self.dateModel?.month.rawValue ?? 0
                let year = self.dateModel?.year ?? 0

                let date = DateType.yearMonthDay.date(year: year, month: month + 1, day: day) ?? Date.now

                self.showAddSchedule.onNext(date)
            })
            .disposed(by: disposeBag)

        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedHeaderView(_:))))
    }
    
    @objc
    private func didTappedHeaderView(_ sender: MonthlyCalendarHeaderView) {
        showSelectPaper.onNext(())
    }
}
