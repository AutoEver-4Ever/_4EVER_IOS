import SwiftUI


struct HomeView: View {
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
                destination: AnyView(QuotesListView())
            ),
            QuickAction(
                title: "주문 관리",
                systemImage: "cart",
                color: .purple,
                destination: AnyView(OrdersListView())
            ),
            QuickAction(
                title: "매입전표",
                systemImage: "receipt",
                color: .orange,
                destination: AnyView(PurchasesListView())
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
                
                Header(title: "차량 외장재 관리")
                    .padding(.horizontal)
                    .padding(.top, 8)

                
                Card {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("안녕하세요!")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("오늘도 효율적인 업무 관리를 시작해보세요.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
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


// MARK: - 임시 화면
struct NewQuoteView: View {
    var body: some View { Text("견적 요청 작성").navigationTitle("견적 요청") }
}

struct QuotesListView: View {
    var body: some View { Text("견적 목록").navigationTitle("견적 목록") }
}

struct OrdersListView: View {
    var body: some View { Text("주문 관리").navigationTitle("주문 관리") }
}

struct PurchasesListView: View {
    var body: some View { Text("매입전표").navigationTitle("매입전표") }
}

// MARK: - Preview
#Preview {
    MainAppView()
}
