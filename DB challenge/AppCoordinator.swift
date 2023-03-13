//
//  AppCoordinator.swift
//  DB challenge
//
//  Created by Zofia Drabek on 13.03.23.
//

import UIKit

class AppCoordinator {
    let keychainHelper: KeychainHelper
    let apiClient: APIClientProtocol
    let persistentContainer: PersistentContainer

    let rootViewController = UIViewController()
    var presentedViewController: UIViewController?
    var postsManager: PostsManager?

    init(
        keychainHelper: KeychainHelper,
        apiClient: APIClientProtocol,
        persistentContainer: PersistentContainer
    ) {
        self.keychainHelper = keychainHelper
        self.apiClient = apiClient
        self.persistentContainer = persistentContainer
    }

    func start() {
        if let userID = keychainHelper.readUserID() {
            presentTimeline(userID: userID)
        } else {
            presentLogin()
        }
    }

    func presentLogin() {
        let loginViewController = LoginViewController { [weak self] userID in
            DispatchQueue.main.async {
                guard let self else { return }
                self.keychainHelper.saveUserID(userID)
                self.presentTimeline(userID: userID)
            }
        }
        present(loginViewController)
    }

    func presentTimeline(userID: String) {
        let postsManager = PostsManager(
            apiClient: apiClient,
            container: self.persistentContainer,
            userID: userID
        )
        self.postsManager = postsManager
        let navigationController = UINavigationController(
            rootViewController: TimelineViewController(postsManager: postsManager) { [weak self] in
                guard let self else { return }
                self.keychainHelper.deleteUserID()
                self.persistentContainer.removeAllFavorites()
                self.presentLogin()
            }
        )
        present(navigationController)
    }

    func present(_ viewController: UIViewController) {
        if let presentedViewController {
            presentedViewController.removeFromParent()
            presentedViewController.view.removeFromSuperview()
            self.presentedViewController = nil
        }

        viewController.willMove(toParent: rootViewController)
        rootViewController.view.addSubview(viewController.view)
        viewController.didMove(toParent: rootViewController)
        rootViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor),
        ])

        presentedViewController = viewController
    }
}
