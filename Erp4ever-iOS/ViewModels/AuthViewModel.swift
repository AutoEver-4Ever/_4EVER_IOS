//
//  AuthViewModel.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/3/25.
//

import Foundation
import Combine          // 리액티브 바인딩에 필요한 프레임워크
import os

// logging
@available(iOS 14.0, *)
private let authVMLog = Logger(
    subsystem: "org.everp.ios",
    category: "AuthViewModel"
)


final class AuthViewModel: NSObject, ObservableObject {
    
    
    // WebView에 주입할 요청
    // @Published -> 값 변경 시 구독자(UI)가 자동으로 갱신함.
    @Published var request: URLRequest?
    
    // 로딩/에러 상태
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // 값 보관
    private var pkce: PKCEPair?
    private var state: String = ""
    private var config: AuthConfig?
    
    // 인가 플로우 시작
    // PKCE/State 생성 -> 인가 URL 구성 -> 요청 준비
    func start(config: AuthConfig) {
        self.config = config
        isLoading = true
        errorMessage = nil
        
        authVMLog.info("[INFO] 인가(Authorization) 플로우 시작")
        
        do {
            // PKCE + State 생성
            let pair = try PKCEGenerator.makePair()
            let generatedState = try StateGenerator.makeState()
            self.pkce = pair
            self.state = generatedState
            
            authVMLog.debug("[DEBUG] PKCE 및 상태 값 생성 완료")
            
            // 인가 URL 구성
            guard let url = config.makeAuthorizationRequestURL(
                codeChallenge: pair.codeChallenge,
                state: generatedState
            ) else {
                self.errorMessage = "인가 URL 생성 실패"
                self.isLoading = false
                authVMLog.error("인가 URL 생성 실패")
                return
            }
            self.request = URLRequest(url: url)
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    // 리다이렉트 수신 처리: code:state 검증 후 code + code_verifier 전달
    func handleRedirect(
        _ url: URL,
        onCode: @escaping (_ code: String, _ codeVerifier: String) -> Void) {
            
            // 설정 존재 확인
            guard let comps = self.config else {
                self.errorMessage = "인가 설정 정보 없음"
                return
            }
            
            // 리다이렉트 대상 검증
            if let host = config?.redirectHost {
                guard url.scheme == config?.redirectScheme,
                      url.host == host,
                      url.path == config?.redirectPath else { return }
            } else {
                guard url.scheme == config?.redirectScheme,
                      url.path == config?.redirectPath else { return }
            }
            
            // 쿼리 파싱
            guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let items = comps.queryItems else {
                self.errorMessage = "리다이렉트 파싱 실패"
                return
            }
            
            // code/state 추출
            guard
                let code = items.first(where: { $0.name == "code" })?.value,
                let receivedState = items.first(where: { $0.name == "state" })?.value,
                receivedState == self.state
            else {
                self.errorMessage = "state 또는 code 검증 실패"
                authVMLog.error("[ERROR] state 또는 code 검증 실패 (state 불일치 혹은 누락)")
                return
            }
    
            // code verifier 준비
            guard let verifier = pkce?.codeVerifier else {
                        self.errorMessage = "code_verifier 추출 실패"
                        authVMLog.error("[ERROR] code_verifier 추출 실패 (PKCE 초기화 누락 가능성)")
                        return
                    }
            
            // callback 호출
            authVMLog.info("[INFO] 인가 코드 수신 완료: 토큰 교환 진행")
            onCode(code, verifier)
    }
    
    // 진행 중 상태 초기화
    func reset() {
        request = nil
        isLoading = false
        errorMessage = nil
        pkce = nil
        state = ""
        config = nil
        authVMLog.notice("[NOTICE ]AuthViewModel 상태 초기화 완료")
    }
}
