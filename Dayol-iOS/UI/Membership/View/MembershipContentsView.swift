//
//  MembershipHeaderView.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/06/20.
//

import UIKit

private enum Design {
    enum Image {
        static func contents(with type: UserActivityType) -> [UIImage?] {
            switch type {
            case .new:
                return [
                    UIImage(namedByLanguage: "imgMembership_new")
                ]
            case .expiredSubscriber:
                return [
                    UIImage(namedByLanguage: "imgMembership_comeback")
                ]
            case .subscriber:
                return [
                    UIImage(namedByLanguage: "imgMembership_exist_header"),
                    UIImage(namedByLanguage: "imgMembership_exist_body")
                ]
            }
        }
    }

    static var imageRefSize: CGSize {
        if isIPad {
            return CGSize(width: 375, height: 667)
        } else {
            return UIScreen.main.bounds.size
        }
    }
}

class MembershipContentsView: UIView {
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.addConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func addSubviews() {
        addSubview(containerStackView)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func configure(_ type: UserActivityType) {
        if type == .subscriber {
            let headerImage = Design.Image.contents(with: type)[safe: 0] ?? UIImage()
            let bodyImage = Design.Image.contents(with: type)[safe: 1] ?? UIImage()

            let headerImageView = makeImageView(with: headerImage)
            // TODO: 실제 구독날자로 변경해야됨.
            let expirationDateView = makeExpirationDateView(with: MembershipManager.shared.membershipExpireAt.date)
            let bodyImageView = makeImageView(with: bodyImage)

            containerStackView.addArrangedSubview(headerImageView)
            containerStackView.addArrangedSubview(expirationDateView)
            containerStackView.addArrangedSubview(bodyImageView)

            containerStackView.setCustomSpacing(30, after: headerImageView)
            containerStackView.setCustomSpacing(35, after: expirationDateView)
        } else {
            let image = Design.Image.contents(with: type).first ?? UIImage()
            let imageView = makeImageView(with: image)
            containerStackView.addArrangedSubview(imageView)
        }
    }

    private func makeImageView(with image: UIImage?) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = image?.resizeToRatio(width: Design.imageRefSize.width)
        return imageView
    }

    private func makeExpirationDateView(with date: Date) -> UIView {
        let outView = UIView()
        outView.translatesAutoresizingMaskIntoConstraints = false
        outView.backgroundColor = .clear

        let inView = UIView()
        inView.translatesAutoresizingMaskIntoConstraints = false
        inView.backgroundColor = .gray100
        inView.layer.cornerRadius = 10
        inView.layer.masksToBounds = true

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .gray900
        descriptionLabel.addLetterSpacing(-0.3)
        descriptionLabel.text = "membership_expiration_date".localized

        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        dateLabel.textColor = .gray900
        dateLabel.addLetterSpacing(-0.31)
        dateLabel.text = "\(date.string(with: .yearMonthDay))"

        inView.addSubview(descriptionLabel)
        inView.addSubview(dateLabel)
        outView.addSubview(inView)

        NSLayoutConstraint.activate([
            outView.heightAnchor.constraint(equalToConstant: 60),

            inView.topAnchor.constraint(equalTo: outView.topAnchor),
            inView.bottomAnchor.constraint(equalTo: outView.bottomAnchor),
            inView.leadingAnchor.constraint(equalTo: outView.leadingAnchor, constant: 20),
            inView.trailingAnchor.constraint(equalTo: outView.trailingAnchor, constant: -20),

            descriptionLabel.centerYAnchor.constraint(equalTo: inView.centerYAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: inView.leadingAnchor, constant: 22),
            dateLabel.centerYAnchor.constraint(equalTo: inView.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: inView.trailingAnchor, constant: -20)
        ])

        return outView
    }
}

