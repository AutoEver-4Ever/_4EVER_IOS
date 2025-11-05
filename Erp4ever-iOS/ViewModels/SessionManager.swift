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
    @Published var currentUser: UserInfoResponseDto?
    
    init() {
        checkTokenOnLaunch()
    }
    
    func checkTokenOnLaunch() {
        if let token = TokenStore.shared.loadAccessToken() {
            isAuthenticated = true
            showLogin = false
            // 앱 재실행 시 저장된 토큰으로 사용자 정보 동기화
            Task { [weak self] in
                do {
                    let info = try await UserService.shared.fetchUserInfo(accessToken: token)
                    await MainActor.run {
                        self?.currentUser = info
                    }
                } catch UserServiceError.unauthorized {
                    // 토큰이 더 이상 유효하지 않으면 세션 초기화
                    TokenStore.shared.clear()
                    await MainActor.run {
                        self?.isAuthenticated = false
                        self?.currentUser = nil
                    }
                } catch {
                    // 기타 오류는 인증 상태는 유지하고 사용자 정보만 비움(옵션)
                    await MainActor.run {
                        self?.currentUser = nil
                    }
                }
            }
        } else {
            isAuthenticated = false
            showLogin = false
        }
    }
    
    func handleAuthSuccess(accessToken: String) {
        do {
            try TokenStore.shared.saveAccessToken(accessToken)
            isAuthenticated = true
            showLogin = false
            // 로그인 성공 후 사용자 정보 조회
            Task { [weak self] in
                do {
                    let info = try await UserService.shared.fetchUserInfo(accessToken: accessToken)
                    await MainActor.run {
                        self?.currentUser = info
                    }
                } catch {
                    // 사용자 정보 조회 실패는 인증 해제까지는 하지 않음. 필요 시 로깅/재시도 로직 추가 가능.
                }
            }
        } catch {
            // 저장 실패 시 로그인 유지
            isAuthenticated = false
            showLogin = true
        }
    }

    func logout() {
      let token = TokenStore.shared.loadAccessToken()
      // 서버 로그아웃은 best-effort로 비동기 수행
      Task {
          await LogoutService.shared.logout(accessToken: token)
      }
      TokenStore.shared.clear()
      currentUser = nil
      isAuthenticated = false
      showLogin = false
    }
}
