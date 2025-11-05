//
//  PurchaseOrderDetailView.swift
//  Erp4ever-iOS
//
//  공급사용 발주서 상세.
//

import SwiftUI

struct PurchaseOrderDetailView: View {
    let id: String
    @StateObject private var vm = PurchaseOrderDetailViewModel()

    private func formatKRW(_ value: Decimal) -> String { let n = NSDecimalNumber(decimal: value); let f = NumberFormatter(); f.numberStyle = .decimal; return "\(f.string(from: n) ?? "0")원" }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if vm.isLoading && vm.detail == nil { ProgressView().padding(.top, 40) }
                else if let err = vm.error, vm.detail == nil {
                    ErrorStateCard(title: "발주서 상세를 불러오지 못했습니다.", message: err) { vm.load(id: id) }
                } else if let d = vm.detail {
                    // 헤더
                    Card {
                        HStack { Text(d.purchaseOrderNumber).font(.title3.weight(.semibold)); Spacer(); StatusLabel(statusCode: invoiceStatusLabel(from: d.statusCode)) }
                        .padding(.bottom, 6)
                        KeyValueRow(key: "발행일", value: d.issueDate)
                        KeyValueRow(key: "납기일", value: d.dueDate)
                        KeyValueRow(key: "총 금액", value: formatKRW(d.totalAmount), valueStyle: .emphasis)
                    }

                    // 공급사
                    Card { CardTitle("공급사"); KeyValueRow(key: "명칭", value: d.supplierCompanyName); if let ref = d.referenceNumber { KeyValueRow(key: "참조번호", value: ref) } }

                    // 품목
                    Card {
                        CardTitle("품목")
                        VStack(spacing: 10) {
                            ForEach(d.items) { item in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack { Text(item.itemName).font(.subheadline.weight(.semibold)).foregroundStyle(.primary); Spacer(); Text(formatKRW(item.totalPrice)).font(.subheadline.weight(.bold)).foregroundStyle(.blue) }
                                    HStack { Text("수량: \(item.quantity ?? 0) \(item.uomName ?? "")").font(.footnote).foregroundStyle(.secondary); Spacer(); Text("단가: \(formatKRW(item.unitPrice))").font(.footnote).foregroundStyle(.secondary) }
                                }
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                            }
                        }
                    }

                    if let note = d.note, !note.isEmpty { Card { CardTitle("비고"); Text(note).font(.subheadline).foregroundStyle(.primary) } }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { if vm.detail == nil { vm.load(id: id) } }
    }
}

#Preview { PurchaseOrderDetailView(id: "PO-1") }

