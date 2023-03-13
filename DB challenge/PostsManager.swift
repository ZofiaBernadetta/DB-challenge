//
//  PostsManager.swift
//  DB challenge
//
//  Created by Zofia Drabek on 12.03.23.
//

import Foundation

class PostsManager {
    let apiClient: APIClientProtocol
    let container: PersistentContainer
    let userID: String
    
    init(apiClient: APIClientProtocol, container: PersistentContainer, userID: String) {
        self.apiClient = apiClient
        self.container = container
        self.userID = userID
    }
    
    var posts = [Post]()
    let notificationName = Notification.Name("com.zofiadrabek.db-challenge.PostsManager.postsDidUpdate")
    
    func fetchPosts() {
        apiClient.fetch(request: PostsRequest(userID: userID)) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let rawPosts):
                DispatchQueue.main.async {
                    let posts = self.applyFavorite(to: rawPosts.map(\.post))
                    self.setPosts(posts)
                }
            case .failure:
                break
            }
        }
    }

    func addFavorite(postID: Post.ID) {
        container.addFavorite(postID)
        setPosts(applyFavorite(to: posts))
    }

    func removeFavorite(postID: Post.ID) {
        container.removeFavorite(postID)
        setPosts(applyFavorite(to: posts))
    }
    
    private func setPosts(_ posts: [Post]) {
        dispatchPrecondition(condition: .onQueue(.main))
        self.posts = posts
        NotificationCenter.default.post(Notification(name: notificationName))
    }
    
    private func applyFavorite(to posts: [Post]) -> [Post] {
        let favoriteIDs = container.fetchAllFavorites()
        return posts.map {
            var post = $0
            post.isFavorite = favoriteIDs.contains(post.id)
            return post
        }
    }
}
