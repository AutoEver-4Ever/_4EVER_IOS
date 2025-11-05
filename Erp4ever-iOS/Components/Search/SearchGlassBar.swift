//
//  SearchGlassBar.swift
//  Erp4ever-iOS
//
//  Liquid glass style search bar with type menu.
//

import SwiftUI

struct SearchGlassBar: View {
    @Binding var text: String
    @Binding var type: String // "quotationNumber" | "customerName" | "managerName"
    let onChange: (String, String) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
            TextField("검색어 입력", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: text) { _, newValue in
                    onChange(newValue, type)
                }
            Divider().frame(height: 18)
            Menu {
                Button("견적번호") { type = "quotationNumber"; if !text.isEmpty { onChange(text, type) } }
                Button("고객명") { type = "customerName"; if !text.isEmpty { onChange(text, type) } }
                Button("담당자") { type = "managerName"; if !text.isEmpty { onChange(text, type) } }
            } label: {
                HStack(spacing: 4) {
                    Text(type == "quotationNumber" ? "견적번호" : (type == "customerName" ? "고객명" : "담당자"))
                        .font(.caption.weight(.semibold))
                    Image(systemName: "chevron.up.chevron.down").font(.caption2)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(12)
        .background(
            Group {
                if #available(iOS 15.0, *) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.ultraThinMaterial)
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white.opacity(0.6))
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)
    }
}

#Preview("SearchGlassBar") {
    StatefulPreviewWrapper(("", "quotationNumber")) { (text, type) in
        SearchGlassBar(text: text, type: type) { _, _ in }
            .padding()
            .background(Color(.systemGroupedBackground))
    }
}

// Helper for preview to create Bindings
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value1: Value
    @State var value2: Value
    var content: (_ binding1: Binding<Value>, _ binding2: Binding<Value>) -> Content

    init(_ values: (Value, Value), content: @escaping (_ binding1: Binding<Value>, _ binding2: Binding<Value>) -> Content) {
        _value1 = State(initialValue: values.0)
        _value2 = State(initialValue: values.1)
        self.content = content
    }

    var body: some View { content($value1, $value2) }
}

