//
//  AuthView.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/3/25.
//

import SwiftUI

 struct AuthView: View {
     @Environment(\.dismiss) private var dismiss
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
                         onCode(code, verifier)
                         dismiss() // 필요 시 닫기
                     }
                 }
             } else {
                 ProgressView()
             }

             if vm.isLoading {
                 Color.black.opacity(0.1).ignoresSafeArea()
                 ProgressView().scaleEffect(1.2)
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
