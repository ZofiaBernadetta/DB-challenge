//
//  Post.swift
//  DB challenge
//
//  Created by Zofia Drabek on 07.03.23.
//

import Foundation

struct Post: Codable, Hashable, Identifiable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
    var isFavorite: Bool
}
