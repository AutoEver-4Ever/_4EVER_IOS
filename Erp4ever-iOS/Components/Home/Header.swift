//
//  Header.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI


struct Header: View {
    var userName: String?
    var onProfileTapped: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            // 좌측 상단 로고
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 32)
                .accessibilityLabel("EVERP 로고")
            Spacer()
            Button(action: onProfileTapped) {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 20, weight: .semibold))
                    if let userName, !userName.isEmpty {
                        Text(userName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(minHeight: 44)
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("프로필 열기")
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    .allowsHitTesting(false)
            )
            .overlay(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.4), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
                    .opacity(0.7)
                    .allowsHitTesting(false)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.clear)
    }
}

#Preview {
    Header(userName: "홍길동")
}
