import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published private(set) var tabs: [DashboardWorkflowTabData] = []
    @Published var selectedTabCode: String?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let dashboardService: DashboardService

    init(dashboardService: DashboardService = .shared) {
        self.dashboardService = dashboardService
    }

    var selectedItems: [DashboardWorkflowItem] {
        tabs.first(where: { $0.tabCode == selectedTabCode })?.items ?? []
    }

    func selectTab(code: String) {
        selectedTabCode = code
    }

    func loadDashboardWorkflows(force: Bool = false) {
        if isLoading { return }
        if !force, !tabs.isEmpty { return }
        guard let token = TokenStore.shared.loadAccessToken() else {
            errorMessage = "세션이 만료되었습니다. 다시 로그인해 주세요."
            tabs = []
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await dashboardService.fetchWorkflows(accessToken: token)
                await MainActor.run {
                    self.tabs = response.tabs
                    if self.selectedTabCode == nil {
                        self.selectedTabCode = response.tabs.first?.tabCode
                    } else if response.tabs.first(where: { $0.tabCode == self.selectedTabCode }) == nil {
                        self.selectedTabCode = response.tabs.first?.tabCode
                    }
                    self.isLoading = false
                }
            } catch DashboardServiceError.unauthorized {
                await MainActor.run {
                    self.errorMessage = "세션이 만료되었습니다. 다시 로그인해 주세요."
                    self.tabs = []
                    self.isLoading = false
                }
            } catch let DashboardServiceError.http(_, body) {
                await MainActor.run {
                    self.errorMessage = body.isEmpty ? "워크플로우를 불러오지 못했습니다." : body
                    self.tabs = []
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "워크플로우를 불러오지 못했습니다."
                    self.isLoading = false
                }
            }
        }
    }
}

#if DEBUG
extension HomeViewModel {
    static func previewModel() -> HomeViewModel {
        let viewModel = HomeViewModel()
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let now = Date()

        let poItems = [
            DashboardWorkflowItem(
                itemId: "PO-2025-001",
                itemTitle: "에버테크 생산설비 발주",
                itemNumber: "PO-2025-001",
                name: "김영수",
                statusCode: "PENDING",
                date: isoFormatter.string(from: now)
            ),
            DashboardWorkflowItem(
                itemId: "PO-2025-002",
                itemTitle: "신규 공정 자재 구매 요청",
                itemNumber: "PO-2025-002",
                name: "박가람",
                statusCode: "APPROVAL",
                date: isoFormatter.string(from: Calendar.current.date(byAdding: .day, value: 2, to: now) ?? now)
            )
        ]

        let arItems = [
            DashboardWorkflowItem(
                itemId: "AR-2025-011",
                itemTitle: "한빛전자 납품 매출 전표",
                itemNumber: "AR-2025-011",
                name: "오서준",
                statusCode: "IN_PROGRESS",
                date: isoFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now)
            )
        ]

        viewModel.tabs = [
            DashboardWorkflowTabData(tabCode: DashboardWorkflowTab.po.rawValue, items: poItems),
            DashboardWorkflowTabData(tabCode: DashboardWorkflowTab.ar.rawValue, items: arItems)
        ]
        viewModel.selectedTabCode = viewModel.tabs.first?.tabCode
        return viewModel
    }
}
#endif
