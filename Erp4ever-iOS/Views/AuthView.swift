//
//  AuthView.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/3/25.
//

 import SwiftUI

 struct AuthView: View {
     @EnvironmentObject private var session: SessionManager
     @StateObject private var vm = AuthViewModel()

     let config: AuthConfig
     /// 인가 코드와 code_verifier를 상위로 전달
     let onCode: (_ code: String, _ codeVerifier: String) -> Void

     var body: some View {
         ZStack {
             if let req = vm.request {
                 WebView(
                     request: req,
                     redirectUrl: config.redirectURL
                 ) { url in
                     vm.handleRedirect(url) { code, verifier in
                         // 시트 닫기는 상위의 상태(showLogin) 변경으로 제어
                         onCode(code, verifier)
                     }
                 }
             } else {
                 ProgressView()
             }

             if vm.isLoading {
                 Color.black.opacity(0.1).ignoresSafeArea()
                 ProgressView().scaleEffect(1.2)
             }

             // 상단 닫기 바 (왼쪽 정렬)
             VStack {
                 HStack {
                     // 닫기: 시트 닫기 (로그인 플로우 종료)
                     Button {
                         session.showLogin = false
                     } label: {
                         HStack(spacing: 6) {
                             Image(systemName: "xmark")
                             Text("닫기")
                         }
                     }
                     Spacer()
                 }
                 .padding(.horizontal, 12)
                 .padding(.vertical, 10)
                 .background(.ultraThinMaterial)
                 .clipShape(RoundedRectangle(cornerRadius: 14))
                 .padding(.top, 10)
                 .padding(.horizontal, 10)
                 Spacer()
             }
         }
         .onAppear { vm.start(config: config) }
         .alert("오류", isPresented: .constant(vm.errorMessage != nil)) {
             Button("확인") { vm.errorMessage = nil }
         } message: {
             Text(vm.errorMessage ?? "")
         }
     }
 }
