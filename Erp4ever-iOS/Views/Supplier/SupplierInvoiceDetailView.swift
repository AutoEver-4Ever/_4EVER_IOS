//
//  SupplierInvoiceDetailView.swift
//  Erp4ever-iOS
//
//  공급사 사용자용 매출 전표 상세 화면.
//

import SwiftUI

struct SupplierInvoiceDetailView: View {
    let id: String
    @StateObject private var vm = SupplierInvoiceDetailViewModel()

    // 금액 포맷 (원화, 천단위 구분)
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
                    // 헤더 블록: 전표번호/상태/발행/납기/총액
                    Card {
                        HStack {
                            Text(d.invoiceNumber)
                                .font(.title3.weight(.semibold))
                            Spacer()
                            StatusLabel(statusCode: invoiceStatusLabel(from: d.statusCode))
                        }
                        .padding(.bottom, 6)

                        KeyValueRow(key: "발행일", value: d.issueDate)
                        KeyValueRow(key: "납기일", value: d.dueDate)
                        KeyValueRow(key: "총 금액", value: formatKRW(d.totalAmount), valueStyle: .emphasis)
                    }

                    // 고객사 정보
                    Card {
                        CardTitle("고객사")
                        KeyValueRow(key: "명칭", value: d.customerName)
                        if let ref = d.referenceNumber { KeyValueRow(key: "참조번호", value: ref) }
                    }

                    // 품목 리스트
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
                                        Text("수량: \(item.quantity) \(item.uomName)")
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

                    // 비고
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

#Preview("SupplierInvoiceDetailView – Mock") {
    let mock = SupplierInvoiceDetail(
        invoiceId: "INV-1",
        invoiceNumber: "AR-2024-001",
        invoiceType: "AR",
        statusCode: "ISSUED",
        issueDate: "2024-01-15",
        dueDate: "2024-02-15",
        customerName: "현대자동차",
        referenceNumber: "ORD-001",
        totalAmount: 9500000,
        note: "조기 납품 요청",
        items: [
            SupplierInvoiceDetailItem(itemId: "I-1", itemName: "프론트 범퍼", quantity: 10, uomName: "EA", unitPrice: 500000, totalPrice: 5000000),
            SupplierInvoiceDetailItem(itemId: "I-2", itemName: "리어 범퍼", quantity: 10, uomName: "EA", unitPrice: 450000, totalPrice: 4500000)
        ]
    )
    let vm = SupplierInvoiceDetailViewModel()
    vm.detail = mock
    return SupplierInvoiceDetailView(id: mock.invoiceId)
}
