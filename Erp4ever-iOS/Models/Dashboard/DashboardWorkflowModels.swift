import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let status: Int
    let success: Bool
    let message: String?
    let data: T?
    let errors: DecodableValue?
}

struct DecodableValue: Decodable {}

struct DashboardWorkflowResponse: Decodable {
    let tabs: [DashboardWorkflowTabData]
}

struct DashboardWorkflowTabData: Decodable, Identifiable {
    let tabCode: String
    let items: [DashboardWorkflowItem]

    var id: String { tabCode }
}

struct DashboardWorkflowItem: Decodable, Identifiable {
    let itemId: String
    let itemTitle: String
    let itemNumber: String
    let name: String
    let statusCode: String
    let date: String

    var id: String { itemId }
}
