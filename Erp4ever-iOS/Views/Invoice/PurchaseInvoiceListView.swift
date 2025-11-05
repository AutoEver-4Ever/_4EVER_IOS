//
//  PurchaseInvoiceListView.swift
//  Erp4ever-iOS
//
//  AR invoice list shown as Purchase in UI.
//

import SwiftUI

struct PurchaseInvoiceListView: View {
    @StateObject private var vm = PurchaseInvoiceListViewModel()
    @State private var company: String = ""

    private func formatKRW(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let f = NumberFormatter(); f.numberStyle = .decimal
        return "\(f.string(from: number) ?? "0")원"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("매입 전표")
                        .font(.title2.bold())
                    Spacer()
                }
                .padding()

                // 간단 검색 (거래처명)
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("거래처명으로 검색", text: $company)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: company) { _, newValue in vm.applyCompany(newValue) }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                )
                .padding(.horizontal)
                .padding(.bottom, 8)

                ScrollView {
                    if vm.isLoading && vm.items.isEmpty {
                        ProgressView().padding(.top, 40)
                    } else if let err = vm.error, vm.items.isEmpty {
                        ErrorStateCard(title: "전표 목록을 불러오지 못했습니다.", message: err) { vm.loadInitial() }
                            .padding(.horizontal)
                            .padding(.top, 40)
                    } else if vm.items.isEmpty {
                        EmptyStateCard(message: "목록이 비어 있습니다.")
                            .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(Array(vm.items.enumerated()), id: \.offset) { idx, item in
                                NavigationLink(destination: PurchaseInvoiceDetailView(id: item.invoiceId)) {
                                    Card {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text(item.invoiceNumber)
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(.blue)
                                                Spacer()
                                                StatusLabel(statusCode: item.statusCode)
                                            }
                                            Group {
                                                HStack { Text("거래처").foregroundColor(.secondary); Spacer(); Text(item.supply.supplierName) }
                                                HStack { Text("발행일").foregroundColor(.secondary); Spacer(); Text(item.issueDate) }
                                                HStack { Text("납기일").foregroundColor(.secondary); Spacer(); Text(item.dueDate) }
                                                HStack { Text("금액").foregroundColor(.secondary); Spacer(); Text(formatKRW(item.totalAmount)).foregroundColor(.blue).bold() }
                                            }
                                            .font(.footnote)
                                        }
                                    }
                                }
                                .onAppear { if idx == vm.items.count - 1 { vm.loadNextPage() } }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                        if vm.isLoading { ProgressView().padding(.bottom, 16) }
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .onAppear { if vm.items.isEmpty { vm.loadInitial() } }
        }
    }
}

#Preview { PurchaseInvoiceListView() }

