//
//  DiaryListViewController.swift
//  Dayol-iOS
//
//  Created by Sungmin on 2020/12/17.
//

import RxSwift

private enum Design {
    static let iconImageTopMargin: CGFloat = 21.0
    static let topIcon = Assets.Image.Home.topIcon

    static let bgColor = UIColor.white

    static let collectionViewHeight: CGFloat = 432.0
    static let itemSize = CGSize(width: 278, height: 432)
    static var itemSpacing: CGFloat {
        guard isPadDevice else {
            return 30.0
        }
        return 60.0
    }
}

class DiaryListViewController: UIViewController {

    let viewModel = DiaryListViewModel()
    let disposeBag = DisposeBag()

    // MARK: - UI

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Design.topIcon
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    let emptyView: HomeEmptyView = {
        let view = HomeEmptyView(style: .diary)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayoutConstraints()
        bind()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard
            viewModel.diaryList.count != 0,
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else { return }

        let insets = calcCollectionViewInset(width: size.width)
        layout.sectionInset = insets
        collectionView.collectionViewLayout.invalidateLayout()
    }

}

// MARK: - Setup UI

extension DiaryListViewController {

    private func setupViews() {
        setupCollectionView()

        view.addSubview(iconImageView)
        view.addSubview(emptyView)
        view.addSubview(collectionView)
        view.backgroundColor = Design.bgColor
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DiaryListCell.self, forCellWithReuseIdentifier: DiaryListCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {

            let insets = calcCollectionViewInset(width: view.bounds.width)
            layout.sectionInset = insets
            layout.scrollDirection = .horizontal
            layout.itemSize = Design.itemSize
            layout.minimumInteritemSpacing = Design.itemSpacing
            layout.minimumLineSpacing = Design.itemSpacing
        }
    }

    private func calcCollectionViewInset(width: CGFloat) -> UIEdgeInsets {
        let itemWidth = Design.itemSize.width
        let horizontalInset = width / 2 - itemWidth / 2

        return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
}

// MARK: - Layout Constraints

extension DiaryListViewController {

    private func setupLayoutConstraints() {
        let layoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: layoutGuide.topAnchor,
                                               constant: Design.iconImageTopMargin),
            iconImageView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: Design.collectionViewHeight),

            emptyView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}