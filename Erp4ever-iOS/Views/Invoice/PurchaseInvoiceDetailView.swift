//
//  PurchaseInvoiceDetailView.swift
//  Erp4ever-iOS
//
//  AR invoice detail shown as Purchase/AP in UI.
//

import SwiftUI

struct PurchaseInvoiceDetailView: View {
    let id: String
    @StateObject private var vm = PurchaseInvoiceDetailViewModel()

    private func formatKRW(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let f = NumberFormatter(); f.numberStyle = .decimal
        return "\(f.string(from: number) ?? "0")원"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if vm.isLoading && vm.detail == nil {
                    ProgressView().padding(.top, 40)
                } else if let err = vm.error, vm.detail == nil {
                    ErrorStateCard(title: "전표 상세를 불러오지 못했습니다.", message: err) { vm.load(id: id) }
                } else if let d = vm.detail {
                    // 헤더
                    Card {
                        HStack {
                            Text(d.invoiceNumber)
                                .font(.title3.weight(.semibold))
                            Spacer()
                            StatusLabel(statusCode: d.statusCode)
                        }
                        .padding(.bottom, 6)

                        KeyValueRow(key: "발행일", value: d.issueDate)
                        KeyValueRow(key: "납기일", value: d.dueDate)
                        KeyValueRow(key: "총 금액", value: formatKRW(d.totalAmount), valueStyle: .emphasis)
                    }

                    // 거래처
                    Card {
                        CardTitle("거래처")
                        KeyValueRow(key: "명칭", value: d.name)
                        if let ref = d.referenceNumber { KeyValueRow(key: "참조번호", value: ref) }
                    }

                    // 항목
                    Card {
                        CardTitle("품목")
                        VStack(spacing: 10) {
                            ForEach(d.items) { item in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(item.itemName)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Text(formatKRW(item.totalPrice))
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(.blue)
                                    }
                                    HStack {
                                        Text("수량: \(item.quantity ?? 0) \(item.uomName)")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text("단가: \(formatKRW(item.unitPrice))")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2))
                                )
                            }
                        }
                    }

                    if let note = d.note, !note.isEmpty {
                        Card {
                            CardTitle("비고")
                            Text(note)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { if vm.detail == nil { vm.load(id: id) } }
    }
}

#Preview("PurchaseInvoiceDetailView – Mock") {
    let mock = PurchaseInvoiceDetail(
        invoiceId: "INV-1",
        invoiceNumber: "AR-2024-001",
        invoiceType: "AR",
        statusCode: "ISSUED",
        issueDate: "2024-01-15",
        dueDate: "2024-02-15",
        name: "현대자동차",
        referenceNumber: "ORD-001",
        totalAmount: 9500000,
        note: "조기 납품 요청",
        items: [
            PurchaseInvoiceDetailItem(itemId: "I-1", itemName: "프론트 범퍼", quantity: 10, unitOfMaterialName: "EA", unitPrice: 500000, totalPrice: 5000000),
            PurchaseInvoiceDetailItem(itemId: "I-2", itemName: "리어 범퍼", quantity: 10, unitOfMaterialName: "EA", unitPrice: 450000, totalPrice: 4500000)
        ]
    )
    let vm = PurchaseInvoiceDetailViewModel()
    vm.detail = mock
    return PurchaseInvoiceDetailView(id: mock.invoiceId)
}

