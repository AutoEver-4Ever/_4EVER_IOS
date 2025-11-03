//
//  PKCEGenerator.swift
//  Erp4ever-iOS
//
//  Created by 김대환 on 11/2/25.
//

import Foundation
import CryptoKit
import Security

struct PKCEPair {
    let codeVerifier: String
    let codeChallenge: String
}

// PKCE 생성기
enum PKCEGenerator {
    private static let verifierLength = 64

    static func makePair() throws -> PKCEPair {
        let verifier = try randomURLSafeString(length: verifierLength)
        
        // verifier를 기반으로 challenge 생성
        let challenge = try makeCodeChallenge(from: verifier)
        return PKCEPair(codeVerifier: verifier, codeChallenge: challenge)
    }

    // S256으로 암호화
    private static func makeCodeChallenge(from verifier: String) throws -> String {
        guard let verifierData = verifier.data(using: .utf8) else {
            throw PKCEError.invalidVerifier
        }
        let digest = SHA256.hash(data: verifierData)
        return Data(digest).base64URLEncodedString().replacingOccurrences(of: "=", with: "")
    }

    private static func randomURLSafeString(length: Int) throws -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            throw PKCEError.secRandomFailed(status)
        }
        let data = Data(bytes)
        // base64url without padding
        return data.base64URLEncodedString().replacingOccurrences(of: "=", with: "")
    }
}

private enum PKCEError: Error {
    case invalidVerifier
    case secRandomFailed(OSStatus)
}

private extension Data {
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}
