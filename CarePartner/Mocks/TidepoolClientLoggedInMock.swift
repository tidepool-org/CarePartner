//
//  TidepoolClientLoggedInMock.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/2/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit

extension TidepoolClient {
    static var loggedInMock: TidepoolClient {
        return TidepoolClient(session: TSession(
            environment: TEnvironment.productionEnvironment,
            accessToken: "accessToken",
            accessTokenExpiration: Date(),
            refreshToken: "refreshToken",
            userId: "9138ecc2-ed54-4254-bcc4-687d37d6398b",
            username: "name@email.com"))
    }
}
