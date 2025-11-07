import SwiftUI


struct HomeView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var isProfileSheetPresented = false

    private var userType: String? { session.currentUser?.userType }

    var body: some View {
        VStack(spacing: 0) {
            // 고정 헤더 (스크롤 밖)
            Header(
                onProfileTapped: { isProfileSheetPresented = true }
            )
            .padding(.top, 8)
            .padding(.horizontal, 12)
            .background(.thinMaterial) // 선택: 고정 느낌 강화
        

            // 아래만 스크롤
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    UserInfoBanner(user: session.currentUser)
                        .padding(.horizontal)

                    QuickActionView(userType: userType)
                        .padding(.horizontal)

                    RecentActivitesView()
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $isProfileSheetPresented) {
            if #available(iOS 16.0, *) {
                ProfileView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            } else {
                ProfileView()
            }
        }
    }
}




#Preview("HomeView – CUSTOMER") {
    let sm = SessionManager()
    sm.isAuthenticated = true
    sm.currentUser = UserInfoResponseDto(
        userId: "preview-customer",
        userName: "고객 관리자",
        loginEmail: "customer-admin@everp.com",
        userRole: "CUSTOMER_ADMIN",
        userType: "CUSTOMER"
    )
    return HomeView()
        .environmentObject(sm)
}

#Preview("HomeView – SUPPLIER") {
    let sm = SessionManager()
    sm.isAuthenticated = true
    sm.currentUser = UserInfoResponseDto(
        userId: "preview-supplier",
        userName: "공급사 관리자",
        loginEmail: "supplier-admin@everp.com",
        userRole: "SUPPLIER_ADMIN",
        userType: "SUPPLIER"
    )
    return HomeView()
        .environmentObject(sm)
}
