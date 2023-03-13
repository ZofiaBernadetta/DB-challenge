//
//  DB_challengeTests.swift
//  DB challengeTests
//
//  Created by Zofia Drabek on 06.03.23.
//

import XCTest
@testable import DB_challenge
import CoreData

final class PostsManagerTests: XCTestCase {
    var apiClient: MockAPIClient!
    var persistentContainer: PersistentContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiClient = MockAPIClient()

        persistentContainer = PersistentContainer(name: "Favorite")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Failed to load stores: \(error), \(error.userInfo)")
            }
        })
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        apiClient = nil
        persistentContainer = nil
    }

    func testFetchPosts() {
        apiClient.rawPosts = [
            .init(userId: 1, id: 1, title: "title", body: "body"),
            .init(userId: 1, id: 2, title: "title", body: "body"),
        ]

        let manager = PostsManager(apiClient: apiClient, container: persistentContainer, userID: "1")
        let exp = expectation(description: "posts loaded")

        let token = NotificationCenter.default.addObserver(
            forName: manager.notificationName,
            object: nil,
            queue: nil
        ) { _ in
            exp.fulfill()
        }

        manager.fetchPosts()
        waitForExpectations(timeout: 1)
        NotificationCenter.default.removeObserver(token)

        XCTAssertEqual(manager.posts, [
            .init(userId: 1, id: 1, title: "title", body: "body", isFavorite: false),
            .init(userId: 1, id: 2, title: "title", body: "body", isFavorite: false),
        ])
    }

    func testFetchPostsWithExistingFavorites() {
        apiClient.rawPosts = [
            .init(userId: 1, id: 1, title: "title", body: "body"),
            .init(userId: 1, id: 2, title: "title", body: "body"),
        ]
        persistentContainer.addFavorite(2)

        let manager = PostsManager(apiClient: apiClient, container: persistentContainer, userID: "1")
        let exp = expectation(description: "posts loaded")

        let token = NotificationCenter.default.addObserver(
            forName: manager.notificationName,
            object: nil,
            queue: nil
        ) { _ in
            exp.fulfill()
        }

        manager.fetchPosts()
        waitForExpectations(timeout: 1)
        NotificationCenter.default.removeObserver(token)

        XCTAssertEqual(manager.posts, [
            .init(userId: 1, id: 1, title: "title", body: "body", isFavorite: false),
            .init(userId: 1, id: 2, title: "title", body: "body", isFavorite: true),
        ])
    }

    func testAddFavorite() {
        apiClient.rawPosts = [
            .init(userId: 1, id: 1, title: "title", body: "body"),
            .init(userId: 1, id: 2, title: "title", body: "body"),
        ]

        let manager = PostsManager(apiClient: apiClient, container: persistentContainer, userID: "1")

        let exp = expectation(description: "posts loaded")

        let token = NotificationCenter.default.addObserver(
            forName: manager.notificationName,
            object: nil,
            queue: nil
        ) { _ in
            exp.fulfill()
        }

        manager.fetchPosts()
        waitForExpectations(timeout: 1)
        NotificationCenter.default.removeObserver(token)

        XCTAssertEqual(manager.posts, [
            .init(userId: 1, id: 1, title: "title", body: "body", isFavorite: false),
            .init(userId: 1, id: 2, title: "title", body: "body", isFavorite: false),
        ])

        manager.addFavorite(postID: 2)

        XCTAssertEqual(manager.posts, [
            .init(userId: 1, id: 1, title: "title", body: "body", isFavorite: false),
            .init(userId: 1, id: 2, title: "title", body: "body", isFavorite: true),
        ])
        XCTAssertEqual(persistentContainer.fetchAllFavorites(), [2])
    }

    func testRemoveFavorite() {
        apiClient.rawPosts = [
            .init(userId: 1, id: 1, title: "title", body: "body"),
            .init(userId: 1, id: 2, title: "title", body: "body"),
        ]
        persistentContainer.addFavorite(2)

        let manager = PostsManager(apiClient: apiClient, container: persistentContainer, userID: "1")

        let exp = expectation(description: "posts loaded")

        let token = NotificationCenter.default.addObserver(
            forName: manager.notificationName,
            object: nil,
            queue: nil
        ) { _ in
            exp.fulfill()
        }

        manager.fetchPosts()
        waitForExpectations(timeout: 1)
        NotificationCenter.default.removeObserver(token)

        XCTAssertEqual(manager.posts, [
            .init(userId: 1, id: 1, title: "title", body: "body", isFavorite: false),
            .init(userId: 1, id: 2, title: "title", body: "body", isFavorite: true),
        ])

        manager.removeFavorite(postID: 2)

        XCTAssertEqual(manager.posts, [
            .init(userId: 1, id: 1, title: "title", body: "body", isFavorite: false),
            .init(userId: 1, id: 2, title: "title", body: "body", isFavorite: false),
        ])
        XCTAssertEqual(persistentContainer.fetchAllFavorites(), [])
    }
}

class MockAPIClient: APIClientProtocol {
    var rawPosts = [PostsRequest.RawPost]()
    func fetch<T: APIRequest>(request: T, completion: @escaping (Result<T.Response, Error>) -> Void) {
        if T.self == PostsRequest.self {
            completion(.success(rawPosts as! T.Response))
        } else {
            fatalError("unknown request")
        }
    }
}
