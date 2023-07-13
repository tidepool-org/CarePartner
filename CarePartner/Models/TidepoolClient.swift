//
//  TidepoolClient.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/27/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit
import LoopKit
import os.log
import AuthenticationServices

@MainActor
class TidepoolClient: ObservableObject {

    private let log = OSLog(category: "TidepoolClient")

    public var sessionStorage: SessionStorage = KeychainManager()

    private let sessionStorageServiceKey = "Tidepool Care Partner"

    private var authenticationSession: ASWebAuthenticationSession?

    @Published var session: TSession?

    var hasSession: Bool {
        return session != nil
    }

    let api: TAPI

    init(session: TSession? = nil) {
        let initialSession = session ?? (try? sessionStorage.getSession(for: sessionStorageServiceKey))
        self.session = initialSession
        self.api = TAPI(clientId: "tidepool-carepartner-ios", redirectURL: URL(string: "org.tidepool.tidepoolkit.auth://redirect")!, session: initialSession)
        Task {
            await api.setLogging(self)
            await api.addObserver(self)
        }
    }

    func login(environment: TEnvironment, sceneDelegate: SceneDelegate) async throws {
        let sessionProvider = ASWebAuthenticationSessionProvider(contextProviding: sceneDelegate)
        let authenticator = OAuth2Authenticator(api: api, environment: environment, sessionProvider: sessionProvider)

        do {
            try await authenticator.login()
        } catch {
            if case ASWebAuthenticationSessionError.canceledLogin = error {
                // Do nothing on cancel
            } else {
                throw error
            }
        }
    }

    func logout() async {
        await api.logout()
        session = nil
    }
}

extension TidepoolClient: TLogging {
    func debug(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        os_log("DEBUG: %{public}@ %{public}@", type: .debug, message, location(function: function, file: file, line: line))
    }

    func info(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        os_log("INFO: %{public}@ %{public}@", type: .info, message, location(function: function, file: file, line: line))
    }

    func error(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        os_log("ERROR: %{public}@ %{public}@", type: .error, message, location(function: function, file: file, line: line))
    }

    private func location(function: StaticString, file: StaticString, line: UInt) -> String {
        return "[\(URL(fileURLWithPath: file.description).lastPathComponent):\(line):\(function)]"
    }
}

extension TidepoolClient: TAPIObserver {
    public func apiDidUpdateSession(_ session: TSession?) {
        do {
            self.session = session
            try sessionStorage.setSession(session, for: sessionStorageServiceKey)
        } catch {
            log.error("Unable to store Tidepool Client session: %{public}@", error.localizedDescription)
        }
    }
}

public protocol SessionStorage {
    func setSession(_ session: TSession?, for service: String) throws
    func getSession(for service: String) throws -> TSession?
}


extension KeychainManager: SessionStorage {
    public func setSession(_ session: TSession?, for service: String) throws {
        try deleteGenericPassword(forService: service)
        guard let session = session else {
            return
        }
        let sessionData = try JSONEncoder.tidepool.encode(session)
        try replaceGenericPassword(sessionData, forService: service)
    }

    public func getSession(for service: String) throws -> TSession? {
        let sessionData = try getGenericPasswordForServiceAsData(service)
        return try JSONDecoder.tidepool.decode(TSession.self, from: sessionData)
    }
}

