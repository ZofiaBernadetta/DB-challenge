//
//  SceneDelegate.swift
//  DB challenge
//
//  Created by Zofia Drabek on 06.03.23.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    lazy var persistentContainer: PersistentContainer = {
        let container = PersistentContainer(name: "Favorite")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let apiClient = APIClient(
            baseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
            decoder: JSONDecoder()
        )

        let appCoordinator = AppCoordinator(
            keychainHelper: KeychainHelper.standard,
            apiClient: apiClient,
            persistentContainer: persistentContainer
        )
        appCoordinator.start()
        self.appCoordinator = appCoordinator
        window.rootViewController = appCoordinator.rootViewController
        self.window = window

        window.makeKeyAndVisible()
    }
}
