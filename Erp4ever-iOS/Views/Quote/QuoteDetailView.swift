//
//  QuoteDetailView.swift
//  Erp4ever-iOS
//
//  Quotation detail screen with API-backed ViewModel.
//

import SwiftUI

struct QuoteDetailView: View {
    let id: String
    @StateObject private var vm = QuoteDetailViewModel()

    private func formatKRW(_ value: Decimal?) -> String {
        let number = NSDecimalNumber(decimal: value ?? 0)
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return "\(f.string(from: number) ?? "0")원"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if vm.isLoading && vm.detail == nil {
                    ProgressView().padding(.top, 40)
                } else if let err = vm.error, vm.detail == nil {
                    ErrorStateCard(title: "상세를 불러오지 못했습니다.", message: err) { vm.load(id: id) }
                } else if let d = vm.detail {
                    // 기본 정보
                    Card {
                        HStack {
                            Text(d.quotationNumber)
                                .font(.title3.weight(.semibold))
                            Spacer()
                            StatusLabel(statusCode: quoteStatusLabel(from: d.statusCode))
                        }
                        .padding(.bottom, 6)

                        KeyValueRow(key: "견적일자", value: d.quotationDate)
                        KeyValueRow(key: "납기일자", value: d.dueDate)
                        KeyValueRow(key: "총 금액", value: formatKRW(d.totalAmount), valueStyle: .emphasis)
                    }

                    // 고객 정보
                    Card {
                        CardTitle("고객 정보")
                        KeyValueRow(key: "고객명", value: d.customerName)
                        if let ceo = d.ceoName { KeyValueRow(key: "대표자", value: ceo) }
                    }

                    // 품목
                    Card {
                        CardTitle("견적 품목")
                        VStack(spacing: 10) {
                            ForEach(d.items) { item in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(item.itemName)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Text(formatKRW(item.amount))
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(.blue)
                                    }
                                    HStack {
                                        Text("수량: \(item.quantity ?? 0) \(item.uomName ?? "")")
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
                            Divider().padding(.vertical, 4)
                            HStack {
                                Text("총 금액").font(.body.weight(.semibold))
                                Spacer()
                                Text(formatKRW(d.totalAmount))
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(.blue)
                            }
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

#Preview("QuoteDetailView – Mock") {
    let mock = QuotationDetail(
        quotationId: "QID-1",
        quotationNumber: "Q2024-001",
        quotationDate: "2024-01-15",
        dueDate: "2024-02-15",
        statusCode: "REVIEW",
        customerName: "현대자동차",
        ceoName: "김대표",
        items: [
            QuotationDetailItem(itemId: "I-1", itemName: "프론트 범퍼", quantity: 10, uomName: "EA", unitPrice: 500000, amount: 5000000),
            QuotationDetailItem(itemId: "I-2", itemName: "리어 범퍼", quantity: 10, uomName: "EA", unitPrice: 450000, amount: 4500000)
        ],
        totalAmount: 9500000
    )
    let vm = QuoteDetailViewModel()
    vm.detail = mock
    return QuoteDetailView(id: mock.quotationId)
}

