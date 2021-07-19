//
//  SplashViewController.swift
//  Dayol-iOS
//
//  Created by Seonho Ban on 2021/05/15.
//

import UIKit
import RxSwift

private enum Design {
    static let logoImage = UIImage(named: "splash_logo")
    static let labelImage = UIImage(named: "splash_label")
}

final class LaunchViewController: DYViewController {
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Design.logoImage
        return imageView
    }()

    private let labelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Design.labelImage
        return imageView
    }()

    private lazy var onboardingView: OnboardingView = {
        let onboadingView = OnboardingView()
        onboadingView.translatesAutoresizingMaskIntoConstraints = false
        onboadingView.alpha = 0
        onboadingView.isHidden = true
        return onboadingView
    }()

    private let launchManager = LaunchManager()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLunchScreen()
        if launchManager.shouldOnboarding {
            showOnboarding()
        } else {
            showHome()
        }
    }

    private func configureLunchScreen() {
        view.backgroundColor = UIColor.splashBackground
        view.addSubview(logoImageView)
        view.addSubview(labelImageView)
        configureConstraints()
    }

    private func showOnboarding() {
        // TODO: 온보딩 뷰 안에서 뷰컨 스위칭하는것도 체크해서 델리게이트로 빼야함.
        view.addSubview(onboardingView)
        configureOnboadingConstraints()

        view.layoutIfNeeded()
        onboardingView.delegate = self
        onboardingView.configureOnboard()

        UIView.animate(withDuration: 0.3) {
            self.logoImageView.isHidden = true
            self.labelImageView.isHidden = true
            self.onboardingView.isHidden = false
            self.onboardingView.alpha = 1.0
        }

        launchManager.shouldOnboarding = !launchManager.shouldOnboarding
    }

    private func showHome() {
        launchManager.launchConfig
            .observe(on: MainScheduler.instance)
            .attachHUD(self.view)
            .subscribe { _ in
                DYLog.i(.info, in: Self.self, value: MembershipManager.shared.info)
                AppDelegate.shared?.window?.switchRootViewController(HomeTabViewController())
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Set Constraints

private extension LaunchViewController {
    func configureConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 265),
            logoImageView.heightAnchor.constraint(equalToConstant: 346),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            labelImageView.widthAnchor.constraint(equalToConstant: 128),
            labelImageView.heightAnchor.constraint(equalToConstant: 17),
            labelImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            labelImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func configureOnboadingConstraints() {
        NSLayoutConstraint.activate([
            onboardingView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            onboardingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - OnboardingDelegate

extension LaunchViewController: OnboardingDelegate {
    func didTapStartButton() {
        showHome()
    }
}
