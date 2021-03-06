//
//  File.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/06/23.
//

import UIKit

enum SubscribeItemType: Hashable {
    static func == (lhs: SubscribeItemType, rhs: SubscribeItemType) -> Bool {
        lhs.title == rhs.title
    }

    struct SubscribeProductInfo: Hashable {
        let title: String
        let price: String
        let description: String
    }

    case year(product: SubscribeProductInfo)
    case month(product: SubscribeProductInfo)

    var order: Int {
        switch self {
        case .year: return 1
        case .month: return 2
        }
    }

    var title: String {
        switch self {
        case .year(let product): return product.title
        case .month(let product): return product.title
        }
    }

    var price: String {
        switch self {
        case .year(let product): return "membership_year_info_price".localized.with(arguments: product.price)
        case .month(let product): return "membership_month_info_price".localized.with(arguments: product.price)
        }
    }

    var description: String {
        switch self {
        case .year(let product): return product.description
        case .month(let product): return product.description
        }
    }

    var emphasisTitleStrings: [String] {
        switch self {
        case .year(let product): return [product.title.components(separatedBy: " ").first ?? ""]
        case .month(let product): return [product.title.components(separatedBy: " ").first ?? ""]
        }
    }

    func buttonTitle(with userActivityType: UserActivityType) -> String {
        switch userActivityType {
        case .new:
            return "membership_subscribe_button_event_title".localized
        case .expiredSubscriber:
            return "membership_subscribe_button_restart_title".localized
        default:
            return ""
        }
    }

    func buttonDescription(with userActivityType: UserActivityType) -> String {
        switch self {
        case .year(let productInfo) where userActivityType == .new:
            return "membership_new_year_subscribe_button_description".localized.with(arguments: productInfo.price)
        case .year(let productInfo) where userActivityType == .expiredSubscriber:
            return "membership_comeback_year_subscribe_button_description".localized.with(arguments: productInfo.price)
        case .month(let productInfo) where userActivityType == .new:
            return "membership_new_month_subscribe_button_description".localized.with(arguments: productInfo.price)
        case .month(let productInfo) where userActivityType == .expiredSubscriber:
            return "membership_comeback_month_subscribe_button_description".localized.with(arguments: productInfo.price)
        default:
            return ""
        }
    }
}

private enum Design {
    case normal, selected
    var containerRadius: CGFloat { 8 }
    var containerBorderWidth: CGFloat {
        switch self {
        case .normal: return 1
        case .selected: return 2
        }
    }
    var containerBorderColor: CGColor {
        switch self {
        case .normal: return UIColor.gray500.cgColor
        case .selected: return UIColor.dayolBrown.cgColor
        }
    }

    static let titleColor: UIColor = .init(red: 34, green: 34, blue: 34, alpha: 0)
    static let titleFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
    static let emphasisTitleFont: UIFont = .systemFont(ofSize: 15, weight: .bold)

    static let priceColor: UIColor = .dayolBrown
    static let priceFont: UIFont = .systemFont(ofSize: 17, weight: .bold)

    static let descriptionColor: UIColor = .gray800
    static let descriptionFont: UIFont = .systemFont(ofSize: 13, weight: .bold)

    static func selectBoxImage(isOn: Bool) -> UIImage? {
        if isOn {
            return UIImage(named: "btnCheckOn")
        } else {
            return UIImage(named: "btnCheckOff")
        }
    }
}

class SubscribeProductView: UIView {
    private let productTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black//Design.titleColor
        label.font = Design.titleFont
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Design.priceColor
        label.font = Design.priceFont
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Design.descriptionColor
        label.font = Design.descriptionFont
        return label
    }()

    private let selectBox: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Design.selectBoxImage(isOn: false), for: .normal)
        return button
    }()

    private let labelContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private var design: Design {
        return isSelected ? .selected : .normal
    }

    var isSelected: Bool = false {
        didSet {
            updateViewIfNeeded()
        }
    }

    var selectHandler: ((SubscribeProductView) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = design.containerRadius
        layer.borderWidth = design.containerBorderWidth
        layer.borderColor = design.containerBorderColor
        layer.masksToBounds = true

        addSubviews()
        addConstraints()
    }

    private(set) var type: SubscribeItemType?

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func addSubviews() {
        labelContainer.addArrangedSubview(productTitleLabel)
        labelContainer.addArrangedSubview(priceLabel)
        labelContainer.addArrangedSubview(descriptionLabel)
        self.addSubview(labelContainer)
        self.addSubview(selectBox)
        selectBox.addTarget(self, action: #selector(didTapSelectBox), for: .touchUpInside)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            labelContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            labelContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            labelContainer.centerYAnchor.constraint(equalTo: centerYAnchor),

            selectBox.widthAnchor.constraint(equalToConstant: 24),
            selectBox.heightAnchor.constraint(equalToConstant: 24),
            selectBox.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            selectBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }

    private func updateViewIfNeeded() {
        layer.borderWidth = design.containerBorderWidth
        layer.borderColor = design.containerBorderColor

        selectBox.setImage(Design.selectBoxImage(isOn: isSelected), for: .normal)
    }

    func configure(with type: SubscribeItemType) {
        self.type = type
        productTitleLabel.text = type.title
        productTitleLabel.adjustPartialStringFont(type.emphasisTitleStrings, partFont: Design.emphasisTitleFont)
        priceLabel.text = type.price
        descriptionLabel.text = type.description
    }
}

// MARK: - Action

private extension SubscribeProductView {
    @objc func didTapSelectBox() {
        if !isSelected {
            selectHandler?(self)
        }
    }
}
