//
//  ContentView.swift
//  Erp4ever-iOS
//
//  Created by OhChangEun on 9/29/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: SessionManager
    
    private let config = AuthConfig(
              authorizationEndpoint: "https://auth.everp.co.kr/oauth2/authorize",
              tokenEndpoint: "https://auth.everp.co.kr/oauth2/token",
              clientID: "everp-ios",
              redirectUri: "everp-ios://callback",
              scopes: ["erp.user.profile", "offline_access"]
          )
    var body: some View {
              ZStack {
                  if session.isAuthenticated {
                      MainAppView()
                  } else {
                      LoginView()
                  }
              }
              .sheet(isPresented: $session.showLogin) {
                  AuthView(config: config) { code, verifier in
                      // 토큰 교환 호출부(간단 버전): 성공 access_token만 저장 가정
                      Task {
                          do {
                              let token = try await AuthService.shared.exchangeCodeForToken(
                                  config: config, code: code,
                                  verifier: verifier
                              )
                              session.handleAuthSuccess(accessToken:token.access_token)
                          } catch {
                              // 실패 시 시트는 유지되고 사용자 재시도 가능
                          }
                      }
                  }
              }
          }
}
