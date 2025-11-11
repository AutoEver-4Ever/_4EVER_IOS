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
    private var displayName: String { user.name.isEmpty ? fallback.user.name : user.name }
    private var roleDescription: String {
        switch vm.profile {
        case .customer:
            return "고객사 담당자"
        case .supplier:
            return "공급사 담당자"
        case .employee(let employee):
            let dept = employee.department?.isEmpty == false ? employee.department! : fallback.user.department
            let position = employee.position?.isEmpty == false ? employee.position! : fallback.user.position
            return "\(dept) · \(position)"
        case .none:
            return "\(fallback.user.department) · \(fallback.user.position)"
        }
    }

    private var user: UserInfo {
        switch vm.profile {
        case .employee(let e):
            return UserInfo(
                name: e.name ?? "",
                email: e.email ?? "",
                phone: e.phoneNumber ?? "",
                department: e.department ?? "",
                position: e.position ?? ""
            )
        case .customer(let c):
            return UserInfo(
                name: c.customerName,
                email: c.email,
                phone: c.phoneNumber,
                department: "고객사",
                position: "담당자"
            )
        case .supplier(let s):
            return UserInfo(
                name: s.supplierUserName,
                email: s.supplierUserEmail,
                phone: s.supplierUserPhoneNumber,
                department: "공급사",
                position: "담당자"
            )
        case .none:
            return fallback.user
        }
    }

    private var company: CompanyInfo {
        switch vm.profile {
        case .customer(let c):
            return CompanyInfo(
                name: c.companyName,
                address: combinedAddress(base: c.baseAddress, detail: c.detailAddress),
                phone: c.officePhone,
                businessNumber: c.businessNumber
            )
        case .supplier(let s):
            return CompanyInfo(
                name: s.companyName,
                address: combinedAddress(base: s.baseAddress, detail: s.detailAddress),
                phone: s.officePhone,
                businessNumber: s.businessNumber
            )
        case .employee, .none:
            return fallback.company
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
                        Text(roleDescription)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white).shadow(radius: 1))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("회사 정보")
                            .font(.headline)
                        VStack(spacing: 10) {
                            InfoRow(label: "회사명", value: company.name)
                            InfoRow(label: "사업자번호", value: company.businessNumber)
                            InfoRow(label: "대표 전화", value: company.phone)
                            InfoRow(label: "주소", value: company.address)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white).shadow(radius: 1))

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

    private func combinedAddress(base: String, detail: String) -> String {
        if detail.isEmpty { return base }
        return "\(base) \(detail)"
    }
}

#Preview {
    ProfileView()
}
