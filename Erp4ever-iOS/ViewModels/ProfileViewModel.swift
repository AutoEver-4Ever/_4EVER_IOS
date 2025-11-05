//
//  ProfileViewModel.swift
//  Erp4ever-iOS
//
//  프로필 조회 뷰모델. 게이트웨이 GET /api/business/profile 연동.
//

import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var profile: EmployeeProfile? = nil
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    private var task: Task<Void, Never>? = nil
    deinit { task?.cancel() }

    func load() {
        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            await MainActor.run { self.isLoading = true; self.error = nil }

            guard let token = TokenStore.shared.loadAccessToken() else {
                await MainActor.run { self.isLoading = false; self.error = "인증 토큰이 없습니다." }
                return
            }

            do {
                let p = try await ProfileService.shared.fetchProfile(accessToken: token)
                await MainActor.run { self.profile = p; self.isLoading = false }
            } catch ProfileServiceError.unauthorized {
                await MainActor.run { self.isLoading = false; self.error = "세션이 만료되었습니다." }
            } catch let ProfileServiceError.http(status, _) {
                await MainActor.run { self.isLoading = false; self.error = "프로필 조회 실패 (\(status))" }
            } catch {
                await MainActor.run { self.isLoading = false; self.error = "알 수 없는 오류가 발생했습니다." }
            }
        }
    }
}

