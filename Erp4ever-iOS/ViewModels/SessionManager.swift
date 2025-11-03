//
//  SessionManager.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/3/25.
//

import Foundation
import Combine

final class SessionManager: ObservableObject {
    
    @Published var isAuthenticated: Bool = false
    @Published var showLogin: Bool = false
    
    init() {
        checkTokenOnLaunch()
    }
    
    func checkTokenOnLaunch() {
        if TokenStore.shared.loadAccessToken() != nil {
            isAuthenticated = true
            showLogin = false
        } else {
            isAuthenticated = false
            showLogin = true
        }
    }
    
    func handleAuthSuccess(accessToken: String) {
        do {
            try TokenStore.shared.saveAccessToken(accessToken)
            isAuthenticated = true
            showLogin = false
        } catch {
            // 저장 실패 시 로그인 유지
            isAuthenticated = false
            showLogin = true
        }
    }

    func logout() {
      TokenStore.shared.clear()
      isAuthenticated = false
      showLogin = true
    }
}
