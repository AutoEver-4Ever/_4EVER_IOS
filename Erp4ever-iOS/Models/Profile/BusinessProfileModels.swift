import Foundation

struct CustomerProfile: Decodable {
    let companyName: String
    let baseAddress: String
    let detailAddress: String
    let officePhone: String
    let businessNumber: String
    let customerName: String
    let phoneNumber: String
    let email: String
}

struct SupplierProfile: Decodable {
    let supplierUserName: String
    let supplierUserEmail: String
    let supplierUserPhoneNumber: String
    let companyName: String
    let businessNumber: String
    let baseAddress: String
    let detailAddress: String
    let officePhone: String
}

enum BusinessProfilePayload: Decodable {
    case customer(CustomerProfile)
    case supplier(SupplierProfile)
    case employee(EmployeeProfile)

    enum CodingKeys: CodingKey {
        case companyName, customerName, supplierUserName, name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.customerName) {
            let value = try CustomerProfile(from: decoder)
            self = .customer(value)
            return
        }

        if container.contains(.supplierUserName) {
            let value = try SupplierProfile(from: decoder)
            self = .supplier(value)
            return
        }

        let employee = try EmployeeProfile(from: decoder)
        self = .employee(employee)
    }
}
