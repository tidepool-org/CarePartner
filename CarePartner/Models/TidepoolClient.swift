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


class TidepoolClient {

    private let log = OSLog(category: "TidepoolClient")

    public var sessionStorage: SessionStorage = KeychainManager()

    private let sessionStorageServiceKey = "Tidepool"

    private var dataSetId: String? {
        didSet {
            // TODO: Store state
        }
    }

    var hasSession: Bool {
        return api.session != nil
    }

    var accountLogin: String? {
        return api.session?.email
    }

    let api: TAPI

    init() {
        self.api = TAPI(automaticallyFetchEnvironments: true)
        api.addObserver(self)
        api.logging = self

        do {
            api.session = try sessionStorage.getSession(for: sessionStorageServiceKey)
        } catch {
            log.error("Unable to fetch Tidepool Client session: %{public}@", error.localizedDescription)
        }
    }

    func logout() async {
        await withCheckedContinuation({ continuation in
            api.logout(completion: { _ in
                continuation.resume()
            })
        })
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
        if session == nil {
            self.dataSetId = nil
        }
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

