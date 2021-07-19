//
//  PaperPresentView.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/01/26.
//

import UIKit
import Combine
import RxSwift

class PaperPresentView: UIView {
    
    // MARK: - Properties
    
    private var paper: Paper
    private let numberOfPapers: Int
    private var contentTop = NSLayoutConstraint()
    private var contentBottom = NSLayoutConstraint()
    private var disposeBag = DisposeBag()
    private let flexibleSize: Bool

    let showPaperSelect = PublishSubject<PaperType>()
    let showAddSchedule = PublishSubject<(Date, ScheduleModalType)>()
    
    var scaleForFit: CGFloat = 0.0 {
        didSet {
            let scale = CGAffineTransform(scaleX: self.scaleForFit, y: self.scaleForFit)
            self.tableView.transform = scale
            self.contentsView.transform = scale
            let constarintConstant: CGFloat = (self.height - self.tableView.frame.height) / 2
            self.contentTop.constant = -constarintConstant
            self.contentBottom.constant = constarintConstant
        }
    }
    
    // MARK: - UI
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        
        return tableView
    }()
    
    var contentsView: DYContentsView = {
        let view = DYContentsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        
        return view
    }()

    init(paper: Paper, count: Int = 1, flexibleSize: Bool = false) {
        self.paper = paper
        self.numberOfPapers = count
        self.flexibleSize = flexibleSize
        super.init(frame: .zero)
        initView()
        thumbnailBind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawThumbnail()
    }

    // MARK: - Init
    
    private func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        reginterIdentifier()
        
        setupPaperBorder()

        addSubview(tableView)
        addSubview(contentsView)

        setupConstraint()
        updatePaper()
    }

    private func thumbnailBind() {
        Observable<Int>
            .interval(RxTimeInterval.seconds(5), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.drawThumbnail()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupConstraint() {
        contentTop = tableView.topAnchor.constraint(equalTo: topAnchor)
        contentBottom = tableView.bottomAnchor.constraint(equalTo: bottomAnchor)

        if self.flexibleSize == false {
            NSLayoutConstraint.activate([
                contentTop, contentBottom,
                tableView.centerXAnchor.constraint(equalTo: centerXAnchor),
                tableView.widthAnchor.constraint(equalToConstant: size.width),
                tableView.heightAnchor.constraint(equalToConstant: height),

                contentsView.topAnchor.constraint(equalTo: tableView.topAnchor),
                contentsView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                contentsView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
                contentsView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
            ])
        }
    }
    
    private func reginterIdentifier() {
        tableView.register(BasePaper.self, forCellReuseIdentifier: BasePaper.className)
        tableView.register(MujiPaperView.self, forCellReuseIdentifier: MujiPaperView.className)
        tableView.register(DailyPaperView.self, forCellReuseIdentifier: DailyPaperView.className)
        tableView.register(GridPaperView.self, forCellReuseIdentifier: GridPaperView.className)
        tableView.register(CornellPaperView.self, forCellReuseIdentifier: CornellPaperView.className)
        tableView.register(QuartetPaperView.self, forCellReuseIdentifier: QuartetPaperView.className)
        tableView.register(WeeklyCalendarView.self, forCellReuseIdentifier: WeeklyCalendarView.className)
        tableView.register(MonthlyCalendarView.self, forCellReuseIdentifier: MonthlyCalendarView.className)
        tableView.register(MonthlyTrackerPaperView.self, forCellReuseIdentifier: MonthlyTrackerPaperView.className)
    }
    
    private func setupPaperBorder() {
        layer.borderWidth = 1
        layer.borderColor = CommonPaperDesign.borderColor.cgColor
    }

    private func drawThumbnail() {
        let cell = self.tableView.cellForRow(at: IndexPath.init(item: 0, section: 0))
        let thumbnail = cell?.asImage()
        DYTestData.shared.addPaperThumbnail(id: self.paper.id, thumbnail: thumbnail)
    }

}

// MARK: - update paper

extension PaperPresentView {
    func set(paper: Paper) {
        self.paper = paper
        updatePaper()
    }

    private func updatePaper() {
        contentsView.setItems(paper.contents)
        contentsView.setDrawData(paper.drawCanvas)
    }
}

extension PaperPresentView {
    var orientaion: Paper.PaperOrientation {
        return Paper.PaperOrientation(rawValue: paper.orientation) ?? .portrait
    }

    var size: CGSize {
        return PaperOrientationConstant.size(orentantion: orientaion)
    }

    var height: CGFloat {
        return size.height * CGFloat(numberOfPapers)
    }
}

extension PaperPresentView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return size.height
    }
}

extension PaperPresentView: UITableViewDataSource {
    var numberOfSections: Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfPapers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let paperType = paper.type
        switch paperType {
        case .monthly:
            guard let date = paper.date else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(MonthlyCalendarView.self, for: indexPath)
            let viewModel = MonthlyCalendarViewModel(date: date)
            cell.configure(viewModel: viewModel, orientation: orientaion)
            cell.showSelectPaper
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] in
                    self?.showPaperSelect.onNext(.monthly)
                })
                .disposed(by: cell.disposeBag)

            cell.showAddSchedule
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] date in
                    self?.showAddSchedule.onNext((date, .monthly))
                })
                .disposed(by: cell.disposeBag)

            return cell
        case .weekly:
            guard let date = paper.date else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(WeeklyCalendarView.self, for: indexPath)
            let viewModel = WeeklyCalendarViewModel(date: date)
            cell.configure(viewModel: viewModel, orientation: orientaion)
            cell.showSelectPaper
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] in
                    self?.showPaperSelect.onNext(.weekly)
                })
                .disposed(by: cell.disposeBag)

            cell.showAddSchedule
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] date in
                    self?.showAddSchedule.onNext((date, .weekly))
                })
                .disposed(by: disposeBag)

            return cell
        case .daily:
            guard let date = paper.date else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(DailyPaperView.self, for: indexPath)
            let viewModel = DailyPaperViewModel(date: date, drawModel: DrawModel())

            cell.configure(viewModel: viewModel, orientation: orientaion)

            return cell
        case .quartet:
            let cell = tableView.dequeueReusableCell(QuartetPaperView.self, for: indexPath)
            let viewModel = PaperViewModel(drawModel: DrawModel())

            cell.configure(viewModel: viewModel, orientation: orientaion)

            return cell
        case .grid:
            let cell = tableView.dequeueReusableCell(GridPaperView.self, for: indexPath)
            let viewModel = PaperViewModel(drawModel: DrawModel())

            cell.configure(viewModel: viewModel, orientation: orientaion)

            return cell
        case .cornell:
            let cell = tableView.dequeueReusableCell(CornellPaperView.self, for: indexPath)
            let viewModel = PaperViewModel(drawModel: DrawModel())

            cell.configure(viewModel: viewModel, orientation: orientaion)

            return cell
        case .tracker:
            let cell = tableView.dequeueReusableCell(MonthlyTrackerPaperView.self, for: indexPath)
            let viewModel = PaperViewModel(drawModel: DrawModel())

            cell.configure(viewModel: viewModel, orientation: orientaion)

            return cell
        case .muji:
            let cell = tableView.dequeueReusableCell(MujiPaperView.self, for: indexPath)
            let viewModel = PaperViewModel(drawModel: DrawModel())

            cell.configure(viewModel: viewModel, orientation: orientaion)

            return cell
        }
    }
}
