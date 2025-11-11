import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: SessionManager
    @StateObject private var viewModel: HomeViewModel
    @State private var isProfileSheetPresented = false

    init(viewModel: HomeViewModel = HomeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var userType: String? { session.currentUser?.userType }
    private var workflowTabs: [DashboardWorkflowTabData] { viewModel.tabs }
    private var selectedWorkflowItems: [DashboardWorkflowItem] { viewModel.selectedItems }
    private var workflowTabSelection: Binding<String> {
        Binding(
            get: { viewModel.selectedTabCode ?? workflowTabs.first?.tabCode ?? "" },
            set: { viewModel.selectTab(code: $0) }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Header(
                onProfileTapped: { isProfileSheetPresented = true }
            )
            .padding(.top, 8)
            .padding(.horizontal, 12)
            .background(.thinMaterial)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    UserInfoBanner(user: session.currentUser)
                        .padding(.horizontal)

                    QuickActionView(userType: userType)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("워크플로우")
                            .font(.headline)

                        workflowTabPicker
                        workflowList
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
        .task {
            viewModel.loadDashboardWorkflows()
        }
        .onChange(of: session.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                viewModel.loadDashboardWorkflows(force: true)
            }
        }
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

    private var workflowTabPicker: some View {
        Picker("워크플로우 탭", selection: workflowTabSelection) {
            ForEach(workflowTabs) { tab in
                Text(DashboardWorkflowTab.title(for: tab.tabCode))
                    .tag(tab.tabCode)
            }
        }
        .pickerStyle(.segmented)
        .disabled(workflowTabs.isEmpty)
    }

    private var workflowList: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("워크플로우를 불러오는 중입니다...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                    Button("다시 시도") {
                        viewModel.loadDashboardWorkflows(force: true)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
            } else if selectedWorkflowItems.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("표시할 워크플로우가 없습니다.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                ForEach(selectedWorkflowItems) { item in
                    DashboardWorkflowRow(item: item)
                        .padding(.vertical, 12)

                    if item.id != selectedWorkflowItems.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

private struct DashboardWorkflowRow: View {
    let item: DashboardWorkflowItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.itemNumber)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)

                Spacer()

                WorkflowStatusBadge(status: item.statusCode)
            }

            Text(item.itemTitle)
                .font(.body)
                .foregroundColor(.primary)

            HStack(spacing: 12) {
                Label(item.name, systemImage: "person.crop.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .labelStyle(.titleAndIcon)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(formattedDate)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var formattedDate: String {
        if let date = DateFormatters.iso8601.date(from: item.date) {
            return DateFormatters.display.string(from: date)
        }
        if let date = DateFormatters.iso8601NoFraction.date(from: item.date) {
            return DateFormatters.display.string(from: date)
        }
        return item.date
    }
}

private struct WorkflowStatusBadge: View {
    let status: String

    private var displayText: String {
        statusDisplayMap[status] ?? status
    }

    var body: some View {
        Text(displayText)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.15))
            .clipShape(Capsule())
    }

    private var statusDisplayMap: [String: String] {
        [
            "PENDING": "대기",
            "APPROVAL": "승인",
            "REJECTED": "반려",
            "IN_PROGRESS": "진행중",
            "COMPLETED": "완료"
        ]
    }
}

private enum DateFormatters {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let iso8601NoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let display: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
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
    return HomeView(viewModel: .previewModel())
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
    return HomeView(viewModel: .previewModel())
        .environmentObject(sm)
}
