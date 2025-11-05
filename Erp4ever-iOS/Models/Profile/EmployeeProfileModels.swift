//
//  EmployeeProfileModels.swift
//  Erp4ever-iOS
//
//  BUSINESS 서비스의 EmployeeProfileDto 디코딩 모델.
//  게이트웨이: GET /api/business/profile
//

import Foundation

struct EmployeeProfile: Decodable {
    // 서버 DTO(EmployeeProfileDto) 필드. 일부 값은 null 일 수 있어 Optional 로 선언
    let name: String?
    let employeeNumber: String?
    let department: String?
    let position: String?
    let hireDate: String?
    let serviceYears: String?
    let email: String?
    let phoneNumber: String?
    let address: String?
}
