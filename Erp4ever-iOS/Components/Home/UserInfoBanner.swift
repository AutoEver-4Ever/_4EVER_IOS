//
//  UserInfoBanner.swift
//  Erp4ever-iOS
//
//  Shows current user summary above quick actions.
//

import SwiftUI

struct UserInfoBanner: View {
    let user: GWUserInfoResponse?

    var body: some View {
        Card {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: "person.fill")
                        .foregroundStyle(.blue)
                        .font(.system(size: 22, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(user?.userName ?? "사용자 정보 로딩 중")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if let email = user?.loginEmail, !email.isEmpty {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let role = user?.userRole, !role.isEmpty {
                        Text(role)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        UserInfoBanner(user: GWUserInfoResponse(
            userId: "1234",
            userName: "김철수",
            loginEmail: "kim@example.com",
            userRole: "ROLE_MM_USER",
            userType: "INTERNAL"
        ))

        UserInfoBanner(user: nil)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

