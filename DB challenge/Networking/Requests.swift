//
//  Requests.swift
//  DB challenge
//
//  Created by Zofia Drabek on 12.03.23.
//

import Foundation

struct PostsRequest: APIRequest {
    typealias Response = [RawPost]
    var userID: String
    
    var endpoint: String {
        "/users/\(userID)/posts"
    }
    
    let method = "GET"
    let parameters = [String: String]()
    let headers = [String: String]()
    
    struct RawPost: Codable {
        var userId: Int
        var id: Int
        var title: String
        var body: String
        
        var post: Post {
            Post(
                userId: userId,
                id: id,
                title: title,
                body: body,
                isFavorite: false
            )
        }
    }
}
