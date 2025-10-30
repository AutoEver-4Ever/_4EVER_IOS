//
//  ProfileModel.swift
//  Erp4ever-iOS
//
//  Created by Admin on 10/30/25.
//

import Foundation
// MARK: - Models

struct Profile: Identifiable {
    let id = UUID()
    var company: CompanyInfo
    var user: UserInfo
}

struct CompanyInfo {
    var name: String
    var address: String
    var phone: String
    var businessNumber: String
}

struct UserInfo {
    var name: String
    var email: String
    var phone: String
    var department: String
    var position: String
}
