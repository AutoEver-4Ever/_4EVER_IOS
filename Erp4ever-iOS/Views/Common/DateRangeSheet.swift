//
//  DateRangeSheet.swift
//  Erp4ever-iOS
//
//  기간 필터용 공통 시트(시작일/종료일 선택).
//

import SwiftUI

struct DateRangeSheet: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    var onApply: () -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(title: "기간 선택") {
                    DatePicker(selection: Binding(get: { startDate ?? Date() }, set: { startDate = $0 }), displayedComponents: .date) {
                        Text("시작일")
                    }
                    DatePicker(selection: Binding(get: { endDate ?? Date() }, set: { endDate = $0 }), displayedComponents: .date) {
                        Text("종료일")
                    }
                }
            }
            .navigationTitle("기간 필터")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소", action: onCancel) }
                ToolbarItem(placement: .confirmationAction) { Button("적용", action: onApply) }
            }
        }
    }
}

