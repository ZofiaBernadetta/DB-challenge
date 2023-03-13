//
//  APIRequest.swift
//  DB challenge
//
//  Created by Zofia Drabek on 12.03.23.
//

protocol APIRequest {
    associatedtype Response: Decodable
    var endpoint: String { get }
    var method: String { get }
    var headers: [String: String] { get }
    var parameters: [String: String] { get }
}
