//
//  ProfileView.swift
//  Erp4ever-iOS
//
//  Created by Admin on 10/30/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionManager
    @StateObject private var vm = ProfileViewModel()

    // 읽기 전용 기본값 (서버 프로필 로딩 전 표시)
    private let fallback = Profile(
        company: CompanyInfo(
            name: "현대자동차",
            address: "서울시 강남구 테헤란로 123",
            phone: "02-1234-5678",
            businessNumber: "123-45-67890"
        ),
        user: UserInfo(
            name: "김철수",
            email: "kim@hyundai.com",
            phone: "010-1234-5678",
            department: "구매팀",
            position: "과장"
        )
    )

    // 편의 접근자
    private var displayName: String {
        vm.profile?.name ?? fallback.user.name
    }
    private var displayDept: String {
        vm.profile?.department ?? fallback.user.department
    }
    private var displayPosition: String {
        vm.profile?.position ?? fallback.user.position
    }

    private var user: UserInfo {
        if let p = vm.profile {
            return UserInfo(
                name: p.name ?? "",
                email: p.email ?? "",
                phone: p.phoneNumber ?? "",
                department: p.department ?? "",
                position: p.position ?? ""
            )
        } else {
            return fallback.user
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // 프로필 카드
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.blue)
                        }
                        Text(displayName)
                            .font(.title3.bold())
                        Text("\(displayDept) · \(displayPosition)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white).shadow(radius: 1))

                    // ✅ 회사/공급사 정보 섹션은 API 연동 전 잠시 제거 (company 참조로 인한 컴파일 에러 방지)

                    // 개인 정보 (읽기 전용)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("개인 정보")
                            .font(.headline)
                        VStack(spacing: 10) {
                            InfoRow(label: "이름", value: user.name)
                            InfoRow(label: "이메일", value: user.email)
                            InfoRow(label: "휴대폰 번호", value: user.phone)
                            InfoRow(label: "부서", value: user.department)
                            InfoRow(label: "직급", value: user.position)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white).shadow(radius: 1))

                    // 기타 메뉴
                    VStack(spacing: 0) {
                        MenuRow(title: "알림 설정")
                        Divider()
                        MenuRow(title: "이용약관")
                        Divider()
                        MenuRow(title: "개인정보처리방침")
                        Divider()
                        MenuRow(title: "로그아웃", isDestructive: true) {
                            session.logout()
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white).shadow(radius: 1))

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .background(Color(.systemGroupedBackground))
            }
            .background(Color(.systemGroupedBackground))
        }
        .onAppear { if vm.profile == nil { vm.load() } }
    }
}

#Preview {
    ProfileView()
}
