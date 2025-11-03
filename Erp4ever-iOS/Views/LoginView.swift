//
//  LoginView.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/3/25.
//

//
//  LoginView.swift
//  EVERP-iOS
//
//  Created by Admin on 11/3/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionManager
    @Environment(\.colorScheme) private var colorScheme

    private let brand = Color(red: 55/255, green: 83/255, blue: 150/255)

    var body: some View {
        ZStack {
            // 은은한 밝은 배경
            LinearGradient(
                colors: colorScheme == .light
                ? [Color(.systemBackground), Color(.secondarySystemBackground)]
                : [Color(.systemBackground), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 40)

                // 중앙 콘텐츠
                VStack(spacing: 16) {
                    // 로고
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .accessibilityLabel("EVERP 로고")
                        .padding(.bottom, 24)

                    // 타이틀 & 서브텍스트
                    VStack(spacing: 8) {
                        Text("현장을 하나로, 조직을 연결하는 ERP")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Text("지금 로그인하고 업무를 시작하세요.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer(minLength: 0)
            }
            // 하단 CTA
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 12) {
                    // 시작하기 버튼
                    Button {
                        session.showLogin = true  // OAuth 로그인 플로우 트리거
                    } label: {
                        Text("로그인 하기")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 16))
                    .tint(brand)
                    .padding(.horizontal, 20)
                    .accessibilityIdentifier("PrimaryStartButton")
                }
                .background(
                    Rectangle()
                        .fill(.thinMaterial)
                        .ignoresSafeArea(edges: Edge.Set.bottom)
                )
                .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionManager())
}
