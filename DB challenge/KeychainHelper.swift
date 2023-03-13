//
//  KeychainHelper.swift
//  DB challenge
//
//  Created by Zofia Drabek on 12.03.23.
//

import Foundation

final class KeychainHelper {
    static let standard = KeychainHelper()
    private init() {}

    let service = "com.zofiadrabek.db-challenge.KeychainHelper"
    let userKey = "user"

    var userIDQuery: [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: userKey,
        ]
    }

    func saveUserID(_ userID: String) {
        var query = userIDQuery
        query[kSecValueData] = Data(userID.utf8)

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            // Successfully added
            return
        }

        if status == errSecDuplicateItem {
            let attributesToUpdate = [kSecValueData: Data(userID.utf8)] as CFDictionary
            SecItemUpdate(userIDQuery as CFDictionary, attributesToUpdate)
        }
    }

    func readUserID() -> String? {
        var query = userIDQuery
        query[kSecReturnData] = true

        var result: CFTypeRef?
        SecItemCopyMatching(query as CFDictionary, &result)

        return (result as? Data).flatMap { String(data: $0, encoding: .utf8) }
    }

    func deleteUserID() {
        SecItemDelete(userIDQuery as CFDictionary)
    }
}
