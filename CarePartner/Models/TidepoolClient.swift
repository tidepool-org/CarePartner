//
//  TidepoolClient.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/27/23.
//

import Foundation
import TidepoolKit
import LoopKit
import os.log


@MainActor
class TidepoolClient: ObservableObject {

    private let log = OSLog(category: "TidepoolClient")

    public var sessionStorage: SessionStorage = KeychainManager()

    private let sessionStorageServiceKey = "Tidepool Care Partner"

    @Published var session: TSession?

    var hasSession: Bool {
        return session != nil
    }

    let api: TAPI

    init() {
        // TODO: eventually tidepool-carepartner-ios
        self.api = TAPI(clientId: "tidepool-loop", redirectURL: URL(string: "org.tidepool.TidepoolKit://redirect")!)
        self.session = try? sessionStorage.getSession(for: sessionStorageServiceKey)
        Task {
            await api.setSession(session)
            await api.setLogging(self)
            await api.addObserver(self)
        }
    }

    func logout() async {
        await api.logout()
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

