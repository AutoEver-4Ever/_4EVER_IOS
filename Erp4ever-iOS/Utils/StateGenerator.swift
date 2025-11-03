//
//  StateGenerator.swift
//  Erp4ever-iOS
//
//  Created by 김대환 on 11/2/25.
//

import Foundation
import Security

enum StateGenerator {
    static func makeState(length: Int = 64) throws -> String {      // state basic length = 64
        // state의 길이가 32 보다 작으면 안전하지 않기 때문에 에러 발생
        guard length >= 32 else { throw StateError.tooShort }
        
        // 0으로 채워진 UInt8 바이트 배열을 length 만큼 생성함.
        var bytes = [UInt8](repeating: 0, count: length)
        
        // 난수 바이트 생성
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {    // 난수 생성 실패시 에러 발생
            throw StateError.secRandomFailed(status)
        }
        // URL-safe Base64 (RFC 4648)로 인코딩하여 '+'가 공백으로 변환되는 문제 방지
        return Data(bytes).base64URLEncodedString(removingPadding: true)
    }
}

private enum StateError: Error {
    case tooShort
    case secRandomFailed(OSStatus)
}

private extension Data {
    // Base64URL encoding: '+' -> '-', '/' -> '_', '=' padding 제거
    func base64URLEncodedString(removingPadding: Bool = true) -> String {
        var s = base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
        if removingPadding {
            s = s.replacingOccurrences(of: "=", with: "")
        }
        return s
    }
}
