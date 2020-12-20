//
//  HomeViewController.swift
//  Dayol-iOS
//
//  Created by Sungmin on 2020/12/09.
//

import UIKit

private enum Constant {

    // layout
    static let iconImageTopMargin: CGFloat = 21.0
}

class HomeViewController: UIViewController {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.Home.pageIcon.image
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayoutConstraints()
    }

}

// MARK: - Setup UI
extension HomeViewController {
    private func setupViews() {
        view.addSubview(iconImageView)
        // TODO: - color 컨벤션 정해지면 수정
        view.backgroundColor = .white

		iconImageView.isUserInteractionEnabled = true

		// TODO: 임시로 넣은 제스처입니다. 구현시 제거해주세요.
		iconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentPasswordViewController)))
    }

	// TODO: 임시로 넣은 제스처입니다. 구현시 제거해주세요.
	@objc
	private func presentPasswordViewController() {
		let passworkViewController = PasswordViewController(password: "1234")
		present(passworkViewController, animated: true, completion: nil)
	}
}

// MARK: - Layout Constraints
extension HomeViewController {

    private func setupLayoutConstraints() {
        let layoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: layoutGuide.topAnchor,
                                               constant: Constant.iconImageTopMargin),
            iconImageView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor)
        ])
    }

}
