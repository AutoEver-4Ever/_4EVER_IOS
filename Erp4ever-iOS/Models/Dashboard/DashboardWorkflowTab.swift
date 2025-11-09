import SwiftUI

enum DashboardWorkflowTab: String, CaseIterable, Identifiable {
    case po = "PO"
    case ap = "AP"
    case ar = "AR"
    case so = "SO"
    case pr = "PR"
    case att = "ATT"
    case lv = "LV"
    case qt = "QT"
    case mes = "MES"
    case inbound = "IN"
    case outbound = "OUT"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .po: return "발주"
        case .ap: return "매입"
        case .ar: return "매출"
        case .so: return "주문"
        case .pr: return "구매"
        case .att: return "근태"
        case .lv: return "휴가"
        case .qt: return "견적"
        case .mes: return "생산"
        case .inbound: return "입고"
        case .outbound: return "출고"
        }
    }

    var systemImage: String {
        switch self {
        case .po: return "cart.badge.plus"
        case .ap: return "arrow.down.doc"
        case .ar: return "arrow.up.doc"
        case .so: return "shippingbox"
        case .pr: return "square.stack.3d.down.right"
        case .att: return "clock"
        case .lv: return "beach.umbrella"
        case .qt: return "doc.text.magnifyingglass"
        case .mes: return "gearshape.2"
        case .inbound: return "tray.and.arrow.down"
        case .outbound: return "tray.and.arrow.up"
        }
    }

    var accentColor: Color {
        switch self {
        case .po: return .blue
        case .ap: return .indigo
        case .ar: return .orange
        case .so: return .teal
        case .pr: return .green
        case .att: return .purple
        case .lv: return .pink
        case .qt: return .cyan
        case .mes: return .brown
        case .inbound: return .mint
        case .outbound: return .red
        }
    }

    static func tab(from code: String) -> DashboardWorkflowTab? {
        DashboardWorkflowTab(rawValue: code.uppercased())
    }

    static func title(for code: String) -> String {
        tab(from: code)?.title ?? code
    }
}
