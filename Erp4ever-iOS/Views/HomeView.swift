import SwiftUI


struct HomeView: View {
    @EnvironmentObject private var session: SessionManager
    // 빠른 작업
    private var quickActions: [QuickAction] {
        [
            QuickAction(
                title: "견적 요청",
                systemImage: "doc.badge.plus",
                color: .blue,
                destination: AnyView(NewQuoteView())
            ),
            QuickAction(
                title: "견적 목록",
                systemImage: "doc.text.magnifyingglass",
                color: .green,
                destination: AnyView(QuoteListView())
            ),
            QuickAction(
                title: "주문 관리",
                systemImage: "cart",
                color: .purple,
                destination: AnyView(OrderListView())
            ),
            QuickAction(
                title: "매입전표",
                systemImage: "receipt",
                color: .orange,
                destination: AnyView(PurchaseListView())
            )
        ]
    }

    // 최근 작업 목업 데이터
    private let recentActivities: [RecentActivity] = [
        .init(type: "견적", title: "Q2024-001 - 범퍼 견적서", date: "2024-01-15", status: "검토중"),
        .init(type: "주문", title: "O2024-005 - 사이드미러 주문", date: "2024-01-14", status: "배송중"),
        .init(type: "견적", title: "Q2024-002 - 헤드라이트 견적서", date: "2024-01-13", status: "승인됨")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Header()
                    .padding(.horizontal)
                    .padding(.top, 8)

                
                UserInfoBanner(user: session.currentUser)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("빠른 작업")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.horizontal)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(quickActions) { action in
                            NavigationLink(destination: action.destination) {
                                Card {
                                    VStack(spacing: 10) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(action.color)
                                                .frame(width: 48, height: 48)
                                            Image(systemName: action.systemImage)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 20, weight: .semibold))
                                        }
                                        Text(action.title)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("최근 활동")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.horizontal)

                    Card {
                        VStack(spacing: 0) {
                            ForEach(Array(recentActivities.enumerated()), id: \.0) { index, activity in
                                ActivityRow(activity: activity)

                                if index != recentActivities.count - 1 {
                                    Divider().padding(.leading, 12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
            .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
    }
}



#Preview {
    MainAppView()
        .environmentObject(SessionManager())
}
