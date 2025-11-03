//
//  TokenStore.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/3/25.
//

import Foundation
import Security

final class TokenStore {
    static let shared = TokenStore()
    private init() {}

    private let service = "everp.auth"
    private let accessAccount = "access_token"

    func saveAccessToken(_ token: String) throws {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accessAccount
        ]

        let attrs: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query.merging(attrs, uniquingKeysWith: { _, new in new }) as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw NSError(domain: "Keychain", code: Int(status))
        }
    }

    // Keychain 에 저장된 액세스 토큰을 불러옴
    // 저장된 액세스 토큰 문자열. 항목이 없거나 읽기에 실패한 경우 `nil`을 반환함.
    func loadAccessToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accessAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }
}
