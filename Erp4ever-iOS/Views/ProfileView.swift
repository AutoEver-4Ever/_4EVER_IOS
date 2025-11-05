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
    @State private var isEditing = false
    @State private var profile = Profile(
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

    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    func handleSave() {
        guard !profile.company.name.isEmpty, !profile.user.name.isEmpty, !profile.user.email.isEmpty else {
            alertMessage = "필수 정보를 모두 입력해주세요."
            showAlert = true
            return
        }
        alertMessage = "정보가 성공적으로 저장되었습니다."
        showAlert = true
        isEditing = false
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
                        Text(vm.profile?.name ?? profile.user.name)
                            .font(.title3.bold())
                        Text("\(vm.profile?.department ?? profile.user.department) · \(vm.profile?.position ?? profile.user.position)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white).shadow(radius: 1))
                    
                    // 고객사 정보
                    VStack(alignment: .leading, spacing: 12) {
                        Text("고객사 정보")
                            .font(.headline)
                        VStack(spacing: 10) {
                            CustomInput(label: "회사명", text: $profile.company.name, editable: isEditing)
                            CustomInput(label: "회사 주소", text: $profile.company.address, editable: isEditing)
                            CustomInput(label: "회사 전화번호", text: $profile.company.phone, editable: isEditing)
                            CustomInput(label: "사업자등록번호", text: $profile.company.businessNumber, editable: isEditing)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white).shadow(radius: 1))
                    
                    // 개인 정보
                    VStack(alignment: .leading, spacing: 12) {
                        Text("개인 정보")
                            .font(.headline)
                        VStack(spacing: 10) {
                            CustomInput(label: "이름", text: Binding(get: { vm.profile?.name ?? profile.user.name }, set: { profile.user.name = $0 }), editable: isEditing)
                            CustomInput(label: "이메일", text: Binding(get: { vm.profile?.email ?? profile.user.email }, set: { profile.user.email = $0 }), editable: isEditing, keyboard: .emailAddress)
                            CustomInput(label: "휴대폰 번호", text: Binding(get: { vm.profile?.phoneNumber ?? profile.user.phone }, set: { profile.user.phone = $0 }), editable: isEditing)
                            CustomInput(label: "부서", text: Binding(get: { vm.profile?.department ?? profile.user.department }, set: { profile.user.department = $0 }), editable: isEditing)
                            CustomInput(label: "직급", text: Binding(get: { vm.profile?.position ?? profile.user.position }, set: { profile.user.position = $0 }), editable: isEditing)
                            // 참고: 입사일/근속기간/주소 등은 추가 섹션으로 확장 가능
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white).shadow(radius: 1))
                    
                    // 편집 모드 버튼
                    if isEditing {
                        HStack(spacing: 12) {
                            Button("취소") { isEditing = false }
                                .buttonStyle(.bordered)
                                .tint(.gray)
                            Button("저장") { handleSave() }
                                .buttonStyle(.borderedProminent)
                                .tint(.blue)
                        }
                        .padding(.horizontal)
                    }
                    
                    // 앱 정보
                    VStack(alignment: .leading, spacing: 10) {
                        Text("앱 정보")
                            .font(.headline)
                        VStack(spacing: 8) {
                            InfoRow(label: "앱 버전", value: "1.0.0")
                            InfoRow(label: "마지막 업데이트", value: "2024-01-15")
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
            }.background(Color(.systemGroupedBackground))
            .toolbar {
                if !isEditing {
                    Button("편집") { isEditing = true }
                        .foregroundColor(.blue)
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("확인", role: .cancel) { }
            }
        }
        .onAppear { if vm.profile == nil { vm.load() } }
    }
    
   
}


#Preview {
    ProfileView()
}
