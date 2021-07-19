//
//  MemberShipViewController.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/06/20.
//

import UIKit
import StoreKit
import RxSwift

// MARK: - ViewModel

private class ViewModel {
    let userActivityType: UserActivityType

    private(set) var products: [SubscribeItemType: SKProduct] = [:]
    private let disposeBag: DisposeBag = DisposeBag()

    init() {
        if let userActivityType = UserActivityType(rawValue: DYUserDefaults.activityType) {
            self.userActivityType = userActivityType
        } else {
            fatalError("No User Activity Type")
        }
    }

    func fetchProducts() -> Single<[SubscribeItemType: SKProduct]> {
        return Single<[SubscribeItemType: SKProduct]>.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            IAPManager.shared.updatedProducts.asObserver()
                .subscribe { event in
                    guard let result = event.element else { return }
                    self.convertToSubscribeProduct(products: result)
                    single(.success(self.products))
                }
                .disposed(by: self.disposeBag)

            IAPManager.shared.fetchProducts(type: .autoSubscription)
            return Disposables.create()
        }
    }

    func payment(key: SubscribeItemType) -> Single<Bool> {
        return Single<Bool>.create { [weak self] single in
            guard
                let self = self,
                let product = self.products.first(where: { $0.key == key })?.value
            else {
                return Disposables.create()
            }
            IAPManager.shared.purchase(product: product)
            IAPManager.shared.purchasedProduct.asObserver()
                .subscribe { event in
                    guard let result = event.element else { return }
                    single(.success(result))
                }
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    private func convertToSubscribeProduct(products: [SKProduct]) {
        products.forEach {
            let productInfo = SubscribeItemType.SubscribeProductInfo(
                title: $0.localizedTitle,
                price: "\($0.price)",
                description: $0.localizedDescription
            )

            switch IAPProductType.AutoSubscriptionProduct(identifier: $0.productIdentifier) {
            case .membershipYear:
                self.products[.year(product: productInfo)] = $0
            case .membershipMonth:
                self.products[.month(product: productInfo)] = $0
            default: break
            }
        }
    }
}

// MARK: - ViewController

private enum Design {
    static let scrollViewBottomInset: CGFloat = 37
    static let selectBoxHeight: CGFloat = 196
}

class MembershipViewController: DYViewController {
    private let subscribeView: MembershipSubscribeView = {
        let subscribeView = MembershipSubscribeView()
        subscribeView.translatesAutoresizingMaskIntoConstraints = false
        subscribeView.backgroundColor = .white
        subscribeView.isHidden = true
        return subscribeView
    }()

    private let contentsView: MembershipContentsView = {
        let view = MembershipContentsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let containerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset.bottom = Design.scrollViewBottomInset
        return scrollView
    }()

    private lazy var leftButton = DYNavigationItemCreator.barButton(type: .back)
    private lazy var rightButton = DYNavigationItemCreator.barButton(type: .cancel)
    private lazy var contentsBottomMargin: NSLayoutConstraint = NSLayoutConstraint()

    private let viewModel = ViewModel()
    private let disposeBag: DisposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setNavigationBar()
        addSubviews()
        addConstraints()
        fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = true
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    func fetch() {
        viewModel.fetchProducts()
            .observe(on: MainScheduler.instance)
            .attachHUD(view)
            .subscribe(onSuccess: { [weak self] products in
                guard let self = self else { return }
                self.setSubscribeView()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Setup View
private extension MembershipViewController {
    func setNavigationBar() {
        let isTopMost = navigationController?.viewControllers.first is Self
        if isTopMost {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
            rightButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
            leftButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        }
    }

    func addSubviews() {
        containerScrollView.addSubview(contentsView)
        view.addSubview(containerScrollView)
        view.addSubview(subscribeView)
        configureComponents()
    }

    func addConstraints() {
        contentsBottomMargin = containerScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            subscribeView.heightAnchor.constraint(equalToConstant: Design.selectBoxHeight),
            subscribeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subscribeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subscribeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            containerScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            contentsBottomMargin,
            containerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentsView.widthAnchor.constraint(equalTo: containerScrollView.widthAnchor),
            contentsView.topAnchor.constraint(equalTo: containerScrollView.topAnchor),
            contentsView.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor),
            contentsView.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor),
            contentsView.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor),
        ])
    }

    func configureComponents() {
        contentsView.layoutIfNeeded()
        contentsView.configure(viewModel.userActivityType)
    }

    func setSubscribeView() {
        let isExist: Bool = self.viewModel.userActivityType == .subscriber

        if !isExist {
            self.subscribeView.delegate = self
            self.subscribeView.configure(self.viewModel.products.map { $0.key }, for: viewModel.userActivityType)
            self.subscribeView.isHidden(isExist)
        }

        contentsBottomMargin.constant = isExist ? .zero : -Design.selectBoxHeight
    }
}

// MARK: - Action

extension MembershipViewController: MembershipSubscribeViewDelegate {
    @objc func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapClose() {
        super.dismiss(animated: true)
    }

    func didTapSubscribe(productView: SubscribeProductView) {
        if let type = productView.type {
            viewModel.payment(key: type)
                .observe(on: MainScheduler.instance)
                .attachHUD(view)
                .subscribe(onSuccess: { [weak self] result in
                    if result {
                        self?.dismiss(animated: true)
                    } else {
                        //TODO: Error Popup
                        DYLog.e(.inAppPurchase, in: Self.self, value: "Purchase Error")
                    }
                })
                .disposed(by: disposeBag)
        }
    }
}
