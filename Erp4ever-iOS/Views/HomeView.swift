import SwiftUI


struct HomeView: View {
    @EnvironmentObject private var session: SessionManager
    
    private var userType: String? {
        session.currentUser?.userType
    }

    

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // 로고
                Header()
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // 사용자 정보
                UserInfoBanner(user: session.currentUser)
                    .padding(.horizontal)
                
                // 빠른 작업
                QuickActionView(userType: userType)
                    .padding(.horizontal)
                
                // 최근 활동
                RecentActivitesView()
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                
            }
            .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
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
